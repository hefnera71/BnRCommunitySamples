# ED25519 package

This package contains a B&R Automation Studio ANSI C library implementing Ed25519 signing and verification, plus a Python command-line utility for signing and verifying files. It is intended for integrity and authenticity checks: signatures do not encrypt the data.

## Key material and formats

The library uses 32-byte Ed25519 keys. `private_key` is the 32-byte private seed; `public_key` is the corresponding 32-byte verification key. The Python utility stores both as 64 ASCII hexadecimal characters. Keep the private key secret and distribute the public key through a trusted channel.

The PLC library intentionally does not expose key generation. TweetNaCl needs a cryptographically secure random source, and this project does not provide a verified PLC CSPRNG integration. The `randombytes` stub in `tweetnacl.c` uses `rand()` and is explicitly insecure, so it must not be used to create keys. Generate keys off-device with the PyNaCl-backed Python utility or an approved key-management tool, then provision the keys securely. The Python utility's `keygen` command is separate from the PLC library API.

The library offers two signed-data layouts:

- Memory layout: 64 binary signature bytes followed by the original data.
- Content layout: `--- BEGIN SIGNATURE ---` and a newline, 128 ASCII hexadecimal signature characters, the end marker `\n--- END  SIGNATURE ---\n`, then the original content. The marker block is 176 bytes. The signature covers only the original data/content.

The content layout is the same format used by the Python utility. The marker strings use LF (`\n`) line endings.

## Automation Studio integration

Add the `ED25519` library to the application. Its declared library dependencies are `FileIO` and `AsBrStr`; these are needed by `EDFileIOHelper` and the buffer/string support. The crypto function blocks use caller-owned memory addressed by `UDINT` pointers. Provide valid, writable buffers of the documented capacity, typically using `ADR(...)` and `SIZEOF(...)` in Structured Text.

The signing and verification function blocks do their work when called; gate their calls with application logic so they are not repeatedly run every cycle for the same request. `EDFileIOHelper`, in contrast, is an asynchronous state machine and must be called cyclically while its operation is active.

**Signing and verification are synchronous operations!**
the calling PLC task remains occupied until the operation completes.
They can extend the task cycle and disturb real-time execution, especially for large payloads.

**Use them only in a low-priority task class configured for idle-time/background processing**, and test execution time and CPU load on the actual PLC with representative worst-case data before deployment. Confirm sufficient cycle-time margin under the machine's full runtime load.

In a runtime test with just one single task on a X20CP1684 in TC#8 with 10ms, the following execution times were measured for `SignMemoryData` and `VerifyMemoryData`:

| content size | SignMemoryData | VerifyMemoryData |
|--------------|----------------|------------------|
| 70 Byte		| ~ 150ms		| ~300ms		   |
| 10 kByte		| ~ 170ms		| ~310ms		   |
| 20 kByte		| ~ 195ms		| ~320ms		   |


## Signing and verification interfaces

### `SignMemoryData`

Signs the bytes at `pData` and writes the binary-signature memory layout to `pBuffer`.

| Direction | Parameter | Meaning |
| --- | --- | --- |
| Input | `pData` | Pointer to the bytes to sign. |
| Input | `dataLen` | Number of bytes to sign. |
| Input | `pBuffer` | Writable output buffer for signature followed by data. |
| Input | `bufferSize` | Output buffer capacity in bytes. |
| Input | `public_key` | 32-byte public key paired with the private seed. |
| Input | `private_key` | 32-byte private seed used to sign. |
| Output | `status` | `0` if signing ran; otherwise an ED25519 error code. |
| Output | `signedDataLen` | Number of output bytes, normally `64 + dataLen`. |

The implementation checks `bufferSize > dataLen + 64`, not `>=`. Allocate at least `dataLen + 65` bytes to pass this check, although the serialized output itself is `dataLen + 64` bytes. `status = 0` indicates the operation ran, not that any separate verification has occurred.

### `VerifyMemoryData`

Verifies the binary-signature memory layout and copies the original data to `pData`.

| Direction | Parameter | Meaning |
| --- | --- | --- |
| Input | `pSignedMessage` | Pointer to the signature-prefixed message. |
| Input | `signedMessageLen` | Total message length, including the 64-byte signature. Must be at least 64 bytes. |
| Input | `pData` | Writable output buffer for verified data. |
| Input | `dataSize` | Capacity of `pData`; must fit the message payload. |
| Input | `public_key` | 32-byte public key to verify against. |
| Output | `status` | `0` if verification was attempted; otherwise an ED25519 error code. |
| Output | `validationResult` | `0` for a valid signature; nonzero for invalid input/signature. |
| Output | `dataLen` | Payload length reported by the verifier. Use the data only when `validationResult = 0`. |

### `SignToContent`

Signs the bytes at `pContent` and writes the content layout with a hexadecimal signature to `pBuffer`.

| Direction | Parameter | Meaning |
| --- | --- | --- |
| Input | `pContent` | Pointer to the content to sign. |
| Input | `contentLen` | Number of content bytes to sign. |
| Input | `pBuffer` | Writable output buffer for marker block followed by content. |
| Input | `bufferSize` | Capacity of `pBuffer`; must be at least `contentLen + 176`. |
| Input | `public_key` | 32-byte public key paired with the private seed. |
| Input | `private_key` | 32-byte private seed used to sign. |
| Output | `status` | `0` if signing ran; otherwise an ED25519 error code. |
| Output | `signedDataLen` | Number of output bytes, normally `contentLen + 176`. |

### `VerifyFromContent`

Reads the hexadecimal signature at the fixed marker offsets, verifies the content, and writes verified content to `pContent`.

| Direction | Parameter | Meaning |
| --- | --- | --- |
| Input | `pBuffer` | Signed content buffer. This buffer is modified and used as scratch space. |
| Input | `bufferLen` | Total signed-content length; must be at least 176 bytes. |
| Input | `pContent` | Writable output buffer for verified content. |
| Input | `contentSize` | Capacity of `pContent`; must fit the content after the 176-byte marker block. |
| Input | `public_key` | 32-byte public key to verify against. |
| Output | `status` | `0` if verification was attempted; otherwise an ED25519 error code. |
| Output | `validationResult` | `0` for a valid signature; nonzero for invalid input/signature. |
| Output | `contentLen` | Content length reported by the verifier. Use the content only when `validationResult = 0`. |

The implementation parses fixed offsets and does not compare the marker text before attempting verification. Supply a correctly formatted content-layout buffer. A zero `status` alone does not mean the signature is valid.

### Hex conversion functions

`EDHexToBytes` accepts `pHexString64`, `sizeHex`, `pByteArray32`, and `sizeByte`; use exactly 64 input characters and a 32-byte output buffer. It returns `0` on conversion or `ed25519_ERR_FH_PARAMETER` if a pointer is null or either size is not exact. The input must contain valid hexadecimal characters; invalid characters are converted as zero nibbles rather than reported as an error.

`EDBytesToHex` accepts `pByteArray32`, `sizeByte`, `pHexString64`, and `sizeHex`; pass `sizeByte = 32` and `sizeHex = 64`. It returns `0` on conversion or `ed25519_ERR_FH_PARAMETER` for invalid pointers/sizes. The implementation also writes a NUL terminator at output byte 64, so provide at least 65 writable bytes even though `sizeHex` must be 64.

Both functions return a `UINT`; they do not have separate `VAR_OUTPUT` parameters.

## `EDFileIOHelper`

This function block asynchronously reads a file into, or writes a buffer from, caller-owned memory. Call it cyclically. The `Enable` input is edge-triggered while the block is idle: set it low between operations, set the command and parameters, then raise it to start. After completion, set `Command` to `ED_FH_CMD_NONE` and lower `Enable` before starting another operation.

| Direction | Parameter | Meaning |
| --- | --- | --- |
| Input | `Enable` | A rising edge starts the selected command when idle. |
| Input | `Command` | `ED_FH_CMD_WRITE_FILE` (1), `ED_FH_CMD_READ_FILE` (2), or `ED_FH_CMD_NONE` (0). |
| Input | `sFileDevice` | Configured FileIO device name, for example `USER`. |
| Input | `sFileName` | File name/path on that device. A write deletes an existing file at this path before creating the replacement. |
| Input | `bytesToTransfer` | Write length for a write. Must be nonzero and no greater than `maxBufferSize`. For a read it is checked against the file size and buffer capacity, but the helper reads the entire file. |
| Input | `maxBufferSize` | Capacity of the external buffer. It must fit the complete file on reads. |
| Input | `pBuffer` | Pointer to the external read/write buffer. |
| Output | `fileStep` | Current state-machine step, useful for diagnostics. |
| Output | `bBusy` | `TRUE` while the asynchronous operation is running. |
| Output | `bError` | `TRUE` when the operation ended with an error. |
| Output | `lastStatus` | Error code from the last failed operation. |
| Output | `status` | `0` on success; otherwise the relevant ED25519/FileIO error code. |
| Output | `bytesRead` | Number of bytes read; set to the complete file size after a successful read. |

For reads, `bytesToTransfer` is not the read length: the implementation obtains the file size and reads the whole file. Ensure `maxBufferSize` can hold that entire file. A write replaces the named file, so check the path and device before starting it.

Library-defined error values are `ed25519_ERR_BUFFERSIZE` (`55555`), `ed25519_ERR_FH_PARAMETER` (`55556`), and `ed25519_ERR_FH_DATASIZE` (`55557`). File I/O failures may also return FileIO error values. Check both `status` and `bError` after the operation finishes.

## Python file-signing utility

The script is `PythonScript/ed25519_tool.py`. It requires Python and PyNaCl:

```text
python -m pip install pynacl
```

Run the commands from the package directory, or pass a path to the script:

```text
python PythonScript/ed25519_tool.py keygen [--priv PRIVATE_KEY_PATH] [--pub PUBLIC_KEY_PATH]
python PythonScript/ed25519_tool.py sign FILE [--key PRIVATE_KEY_PATH]
python PythonScript/ed25519_tool.py verify FILE [--key PUBLIC_KEY_PATH]
```

Commands and parameters:

- `keygen` creates a key pair. `--priv` selects the private-key output path (default `secret.key`); `--pub` selects the public-key output path (default `public.key`). Both files contain 64 ASCII hexadecimal characters. Existing files at those paths are overwritten.
- `sign FILE` signs `FILE` in place, prepending the content-layout signature block. `--key` selects the private-key file (default `secret.key`). If the file already begins with a recognizable signature block, the script removes that block and signs the remaining content again.
- `verify FILE` verifies the signature block at the beginning of `FILE` and reports whether the signature is valid. `--key` selects the public-key file (default `public.key`).

Example:

```text
python PythonScript/ed25519_tool.py keygen --priv machine-secret.key --pub machine-public.key
python PythonScript/ed25519_tool.py sign document.bin --key machine-secret.key
python PythonScript/ed25519_tool.py verify document.bin --key machine-public.key
```

Signing modifies the input file; keep a backup if the original must be preserved. Protect private-key files and use the public key from a trusted source when verifying. The script exits with a nonzero status on reported errors.

## Licensing

The ED25519 package code, including its Python utility and package-specific changes, is licensed under the MIT License; see [ED25519/LICENSE.txt](ED25519/LICENSE.txt). The included TweetNaCl base implementation remains public domain, as stated by the [upstream TweetNaCl project](https://tweetnacl.cr.yp.to/). Package-specific modifications within `tweetnacl.c` are covered by the package MIT license.

## Automation Studio sample task

The `Tst25519` IEC task demonstrates the library's memory and content APIs. See [Main.st](Tst25519/Main.st) for the flow logic and [Variables.var](Tst25519/Variables.var) for the start-step constants, buffers, and result flags. While online, set `testStep` to a flow's start value; it runs automatically and returns to `TEST_STEP_IDLE` (`0`).

| Start value | Sequence | Expected result |
| --- | --- | --- |
| `10` (`TEST_STEP_MEMORY_SIGN`) | Signs the generated data in memory, then verifies it with the internal public key. | `dataOut` matches `data`; `memoryVerificationSucceeded` is `TRUE` when verification passes. |
| `20` (`TEST_STEP_CONTENT_SIGN`) | Signs the generated data in the marker-delimited format, writes and reads `USER/SignInContent.txt`, then verifies the loaded content. | `contentLoaded` matches `data`; `contentFileVerificationSucceeded` is `TRUE` when verification passes. |
| `30` (`TEST_STEP_EXTERNAL_LOAD`) | Reads `USER/ExternSignedContent.txt` and verifies it with `sPublicKeyFromExtFile`. | `externalVerificationSucceeded` is `TRUE` when verification passes. The matching signed test file is included at [ExtSignedTestFile/ExternSignedContent.txt](ExtSignedTestFile/ExternSignedContent.txt); copy it to the PLC `USER` device as `ExternSignedContent.txt` before running this sequence. |

Each result flag is cleared when its sequence starts. `TRUE` means the verification call completed with `status = 0` and `validationResult = 0`; `FALSE` means verification did not succeed or the flow stopped before verification. Inspect the relevant function-block status and `testStep` when diagnosing a failure. 

Please note: even editing a signed file with a text editor can lead to failed verification, for example when different EOL, different Encoding is used. This is on purpose and no failure of the function (as the file has changed even if the changes are just done in unprintable characters).

**WARNING: The keys embedded in the task are examples for this sample and must not be used as production credentials.**