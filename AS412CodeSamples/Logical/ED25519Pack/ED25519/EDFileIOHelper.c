/********************************************************************
 * Library: ED25519
 * File: EDFileIOHelper.c
 * License: MIT; see LICENSE.txt in this directory.
 *
 * Implementation of the EDFileIOHelper function block.
 *
 * The function block implements a state machine for file handling with
 * the FileIO library:
 *   writeFile : delete (if it exists) -> create -> open -> write -> close
 *   readFile  : file info -> size check -> open -> read -> close
 *
 * All parameters are direct VAR_INPUT / VAR_OUTPUT members of the
 * function block instance, therefore the C code accesses them directly
 * through "inst->". The transfer buffer is always an external buffer
 * provided by the caller via pBuffer.
 *
 * A library function block has no _INIT method. The initialisation is
 * therefore done lazily: the state machine validates the parameters and
 * starts the flow as soon as a command is received.
 *
 * Command handshake (Command is a VAR_INPUT and can therefore not be
 * reset by the function block itself):
 *   1. the caller sets Command to ED_FH_CMD_WRITE_FILE or ED_FH_CMD_READ_FILE
 *   2. the function block runs the flow, bBusy is TRUE while it is running
 *   3. when the flow has finished, bBusy is FALSE and status holds the
 *      result (0 = no error, otherwise the FileIO error code)
 *   4. the caller resets Command to ED_FH_CMD_NONE, then the function block
 *      goes back to ED_FH_STEP_IDLE and is ready for the next flow
 * The internal member "lastCommand" is used as latch for this handshake,
 * so a command that stays set does not restart the flow again and again.
 *
 * All FileIO function blocks are asynchronous. A status of 16#FFFF (65535)
 * means "busy, not finished yet" - in that case the state is kept and the
 * function block is simply called again in the next cycle.
 ********************************************************************/

#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

	#include "ED25519.h"
	#include <FileIO.h>
	#include <AsBrStr.h>

#ifdef __cplusplus
	};
#endif

/* status value of a not yet finished (busy) asynchronous function block call */
#define ED_FH_STATUS_BUSY 0xFFFF

/* -------------------------------------------------------------------------
 * Helper: validate the user supplied parameters
 * Returns 0 when everything is fine, otherwise the error code to report.
 * ---------------------------------------------------------------------- */
static UINT EDFileIOHelperCheckParams(struct EDFileIOHelper* inst)
{
	/* a file device must be given */
	if (brsstrlen((UDINT)inst->sFileDevice) == 0)
	{
		return ed25519_ERR_FH_PARAMETER;
	}

	/* a file name must be given */
	if (brsstrlen((UDINT)inst->sFileName) == 0)
	{
		return ed25519_ERR_FH_PARAMETER;
	}

	/* the number of bytes to transfer must be greater than zero */
	if (inst->bytesToTransfer == 0 && inst->Command == ED_FH_CMD_WRITE_FILE)
	{
		return ed25519_ERR_FH_DATASIZE;
	}

	/* the number of bytes to transfer must not exceed the available buffer */
	if (inst->bytesToTransfer > inst->maxBufferSize)
	{
		return ed25519_ERR_FH_DATASIZE;
	}

	/* an external buffer must be provided */
	if (inst->pBuffer == 0)
	{
		return ed25519_ERR_FH_PARAMETER;
	}

	return 0;
}

/* -------------------------------------------------------------------------
 * Helper: prepare the function block for a new flow
 * ---------------------------------------------------------------------- */
static void EDFileIOHelperStart(struct EDFileIOHelper* inst, USINT nextStep)
{
	inst->internal.fileOffset = 0;
	/* a stale file identifier from a previous flow must not be closed again */
	inst->internal.FileOpen_0.ident = 0;
	inst->bBusy = 1;
	inst->bError = 0;
	inst->lastStatus = 0;
	inst->status = 0;
	inst->fileStep = nextStep;
	inst->bytesRead = 0;
	/* clear the info structure so no stale data can be evaluated */
	brsmemset((UDINT)&inst->internal.fileInfo, 0, sizeof(inst->internal.fileInfo));
}

/* -------------------------------------------------------------------------
 * Helper: set the function block into the error state
 * The file is closed afterwards via the ED_FH_STEP_ERROR_CLOSE state.
 * ---------------------------------------------------------------------- */
static void EDFileIOHelperFail(struct EDFileIOHelper* inst, UINT status)
{
	inst->lastStatus = status;
	inst->status = status;
	inst->bError = 1;
	inst->bBusy = 0;
	inst->fileStep = ED_FH_STEP_ERROR_CLOSE;
}

/* -------------------------------------------------------------------------
 * EDFileIOHelper - state machine for file handling
 * ---------------------------------------------------------------------- */
void EDFileIOHelper(struct EDFileIOHelper* inst)
{
	UINT uStatus;

	switch (inst->fileStep)
	{
		case ED_FH_STEP_IDLE:
			/* wait for a command from the user */
			/* the command is edge detected, so a command that stays set does
			   not restart the flow over and over again */
			if (inst->Enable == 1 && inst->internal.lastEnable == 0)
			{
				if (inst->Command == ED_FH_CMD_WRITE_FILE)
				{
					uStatus = EDFileIOHelperCheckParams(inst);

					if (uStatus != 0)
					{
						EDFileIOHelperFail(inst, uStatus);
					}
					else
					{
						EDFileIOHelperStart(inst, ED_FH_STEP_WRITE_DELETE);
					}
				}
				else if (inst->Command == ED_FH_CMD_READ_FILE)
				{
					uStatus = EDFileIOHelperCheckParams(inst);

					if (uStatus != 0)
					{
						EDFileIOHelperFail(inst, uStatus);
					}
					else
					{
						EDFileIOHelperStart(inst, ED_FH_STEP_READ_INFO);
					}
				}
			}
			inst->internal.lastEnable = inst->Enable;
		break;

		case ED_FH_STEP_WRITE_DELETE:
			/* writeFile: delete an already existing file first */
			inst->internal.FileDelete_0.enable = 1;
			inst->internal.FileDelete_0.pDevice = (UDINT)inst->sFileDevice;
			inst->internal.FileDelete_0.pName = (UDINT)inst->sFileName;

			FileDelete(&inst->internal.FileDelete_0);

			if (inst->internal.FileDelete_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileDelete_0.status == 0 ||
					inst->internal.FileDelete_0.status == fiERR_FILE_NOT_FOUND)
				{
					/* file is gone or was never there -> create it */
					inst->fileStep = ED_FH_STEP_WRITE_CREATE;
				}
				else
				{
					EDFileIOHelperFail(inst, inst->internal.FileDelete_0.status);
				}
			}
		break;

		case ED_FH_STEP_WRITE_CREATE:
			/* writeFile: create the file */
			inst->internal.FileCreate_0.enable = 1;
			inst->internal.FileCreate_0.pDevice = (UDINT)inst->sFileDevice;
			inst->internal.FileCreate_0.pFile = (UDINT)inst->sFileName;

			FileCreate(&inst->internal.FileCreate_0);

			if (inst->internal.FileCreate_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileCreate_0.status == 0 ||
					inst->internal.FileCreate_0.status == fiERR_EXIST)
				{
					inst->fileStep = ED_FH_STEP_WRITE_OPEN;
				}
				else
				{
					EDFileIOHelperFail(inst, inst->internal.FileCreate_0.status);
				}
			}
		break;

		case ED_FH_STEP_WRITE_OPEN:
			/* writeFile: open the file for read/write */
			inst->internal.FileOpen_0.enable = 1;
			inst->internal.FileOpen_0.mode = fiREAD_WRITE;
			inst->internal.FileOpen_0.pDevice = (UDINT)inst->sFileDevice;
			inst->internal.FileOpen_0.pFile = (UDINT)inst->sFileName;

			FileOpen(&inst->internal.FileOpen_0);

			if (inst->internal.FileOpen_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileOpen_0.status == 0)
				{
					inst->internal.fileOffset = 0;
					inst->fileStep = ED_FH_STEP_WRITE_WRITE;
				}
				else
				{
					/* no valid file handle -> nothing has to be closed */
					inst->internal.FileOpen_0.ident = 0;
					EDFileIOHelperFail(inst, inst->internal.FileOpen_0.status);
				}
			}
		break;

		case ED_FH_STEP_WRITE_WRITE:
			/* writeFile: write the external buffer to the file */
			inst->internal.FileWrite_0.enable = 1;
			inst->internal.FileWrite_0.ident = inst->internal.FileOpen_0.ident;
			inst->internal.FileWrite_0.offset = inst->internal.fileOffset;
			inst->internal.FileWrite_0.pSrc = inst->pBuffer;
			inst->internal.FileWrite_0.len = inst->bytesToTransfer;

			FileWrite(&inst->internal.FileWrite_0);

			if (inst->internal.FileWrite_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileWrite_0.status == 0)
				{
					inst->internal.fileOffset = inst->internal.fileOffset + inst->bytesToTransfer;
					inst->fileStep = ED_FH_STEP_WRITE_CLOSE;
				}
				else
				{
					EDFileIOHelperFail(inst, inst->internal.FileWrite_0.status);
				}
			}
		break;

		case ED_FH_STEP_WRITE_CLOSE:
			/* writeFile: close the file and finish */
			inst->internal.FileClose_0.enable = 1;
			inst->internal.FileClose_0.ident = inst->internal.FileOpen_0.ident;

			FileClose(&inst->internal.FileClose_0);

			if (inst->internal.FileClose_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileClose_0.status == 0)
				{
					inst->internal.FileOpen_0.ident = 0;
					inst->bBusy = 0;
					inst->bError = 0;
					inst->status = 0;
					inst->fileStep = ED_FH_STEP_IDLE;
				}
				else
				{
					EDFileIOHelperFail(inst, inst->internal.FileClose_0.status);
				}
			}
		break;

		case ED_FH_STEP_READ_INFO:
			/* readFile: get the file info to know the actual file size */

			inst->internal.FileInfo_0.enable = 1;
			inst->internal.FileInfo_0.pDevice = (UDINT)inst->sFileDevice;
			inst->internal.FileInfo_0.pName = (UDINT)inst->sFileName;
			inst->internal.FileInfo_0.pInfo = (UDINT)&inst->internal.fileInfo;

			FileInfo(&inst->internal.FileInfo_0);

			if (inst->internal.FileInfo_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileInfo_0.status == 0)
				{
					inst->fileStep = ED_FH_STEP_READ_CHK_SIZE;
				}
				else
				{
					/* file not found or info failed */
					EDFileIOHelperFail(inst, inst->internal.FileInfo_0.status);
				}
			}
		break;

		case ED_FH_STEP_READ_CHK_SIZE:
			/* readFile: validate that the file fits into the available buffer */
			if (inst->internal.fileInfo.size > inst->maxBufferSize)
			{
				/* the file does not fit into the available buffer at all */
				EDFileIOHelperFail(inst, ed25519_ERR_BUFFERSIZE);
			}
			else if (inst->bytesToTransfer > inst->internal.fileInfo.size)
			{
				/* more bytes requested than the file contains */
				EDFileIOHelperFail(inst, ed25519_ERR_BUFFERSIZE);
			}
			else
			{
				/* size is consistent -> open and read */
				inst->fileStep = ED_FH_STEP_READ_OPEN;
			}
		break;

		case ED_FH_STEP_READ_OPEN:
			/* readFile: open the existing file for read/write */
			inst->internal.FileOpen_0.enable = 1;
			inst->internal.FileOpen_0.mode = fiREAD_WRITE;
			inst->internal.FileOpen_0.pDevice = (UDINT)inst->sFileDevice;
			inst->internal.FileOpen_0.pFile = (UDINT)inst->sFileName;

			FileOpen(&inst->internal.FileOpen_0);

			if (inst->internal.FileOpen_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileOpen_0.status == 0)
				{
					inst->internal.fileOffset = 0;
					inst->fileStep = ED_FH_STEP_READ_READ;
				}
				else
				{
					/* no valid file handle -> nothing has to be closed */
					inst->internal.FileOpen_0.ident = 0;
					EDFileIOHelperFail(inst, inst->internal.FileOpen_0.status);
				}
			}
		break;

		case ED_FH_STEP_READ_READ:
			/* readFile: read the file into the external buffer */
			inst->internal.FileRead_0.enable = 1;
			inst->internal.FileRead_0.ident = inst->internal.FileOpen_0.ident;
			inst->internal.FileRead_0.offset = inst->internal.fileOffset;
			inst->internal.FileRead_0.pDest = inst->pBuffer;
			inst->internal.FileRead_0.len = inst->internal.fileInfo.size;

			FileRead(&inst->internal.FileRead_0);

			if (inst->internal.FileRead_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileRead_0.status == 0)
				{
					inst->internal.fileOffset = inst->internal.fileOffset + inst->internal.fileInfo.size;
					inst->bytesRead = inst->internal.fileInfo.size;
					inst->fileStep = ED_FH_STEP_READ_CLOSE;
				}
				else
				{
					EDFileIOHelperFail(inst, inst->internal.FileRead_0.status);
				}
			}
		break;

		case ED_FH_STEP_READ_CLOSE:
			/* readFile: close the file and finish */
			inst->internal.FileClose_0.enable = 1;
			inst->internal.FileClose_0.ident = inst->internal.FileOpen_0.ident;

			FileClose(&inst->internal.FileClose_0);

			if (inst->internal.FileClose_0.status != ED_FH_STATUS_BUSY)
			{
				if (inst->internal.FileClose_0.status == 0)
				{
					inst->internal.FileOpen_0.ident = 0;
					inst->bBusy = 0;
					inst->bError = 0;
					inst->status = 0;
					inst->fileStep = ED_FH_STEP_IDLE;
				}
				else
				{
					EDFileIOHelperFail(inst, inst->internal.FileClose_0.status);
				}
			}
		break;

		case ED_FH_STEP_ERROR_CLOSE:
			/* error path: close the file before bailing out */
			if (inst->internal.FileOpen_0.ident != 0)
			{
				/* a file was opened -> close it first */
				inst->internal.FileClose_0.enable = 1;
				inst->internal.FileClose_0.ident = inst->internal.FileOpen_0.ident;

				FileClose(&inst->internal.FileClose_0);

				if (inst->internal.FileClose_0.status != ED_FH_STATUS_BUSY)
				{
					inst->internal.FileOpen_0.ident = 0;
					/* keep the original error code, the result of the close
					   operation is less important than the error that aborted
					   the flow */
					inst->status = inst->lastStatus;
					inst->fileStep = ED_FH_STEP_ERROR;
				}
			}
			else
			{
				/* no file was opened -> bail out directly */
				inst->status = inst->lastStatus;
				inst->fileStep = ED_FH_STEP_ERROR;
			}
		break;

		case ED_FH_STEP_ERROR:
			/* error happened -> release to idle so a new command can be started */
			inst->bBusy = 0;
			inst->fileStep = ED_FH_STEP_IDLE;
		break;

		default:
			/* unknown state -> reset to idle, the command handshake makes sure
			   that a running command does not restart the flow */
			inst->bBusy = 0;
			inst->fileStep = ED_FH_STEP_IDLE;
		break;
	}
}
