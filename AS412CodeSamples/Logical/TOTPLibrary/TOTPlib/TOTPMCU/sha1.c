#include "sha1.h"

typedef struct {
  uint32_t buffer[BLOCK_LENGTH/4];
  uint32_t state[HASH_LENGTH/4];
  uint8_t bufferOffset;
  uint32_t byteCount;
  uint8_t keyBuffer[BLOCK_LENGTH];
  uint8_t innerHash[HASH_LENGTH];
} Sha1Context;


#define SHA1_K0 0x5a827999
#define SHA1_K20 0x6ed9eba1
#define SHA1_K40 0x8f1bbcdc
#define SHA1_K60 0xca62c1d6

const uint8_t sha1InitState[] = {
  0x01,0x23,0x45,0x67, // H0
  0x89,0xab,0xcd,0xef, // H1
  0xfe,0xdc,0xba,0x98, // H2
  0x76,0x54,0x32,0x10, // H3
  0xf0,0xe1,0xd2,0xc3  // H4
};

void init(void *contextPtr) {
  Sha1Context *context = (Sha1Context*)contextPtr;
  memcpy(context->state,sha1InitState,HASH_LENGTH);
  context->byteCount = 0;
  context->bufferOffset = 0;
}

uint32_t rol32(uint32_t number, uint8_t bits) {
  return ((number << bits) | (uint32_t)(number >> (32-bits)));
}

void hashBlock(Sha1Context *context) {
  uint8_t i;
  uint32_t a,b,c,d,e,t;

  a=context->state[0];
  b=context->state[1];
  c=context->state[2];
  d=context->state[3];
  e=context->state[4];
  for (i=0; i<80; i++) {
    if (i>=16) {
      t = context->buffer[(i+13)&15] ^ context->buffer[(i+8)&15] ^ context->buffer[(i+2)&15] ^ context->buffer[i&15];
      context->buffer[i&15] = rol32(t,1);
    }
    if (i<20) {
      t = (d ^ (b & (c ^ d))) + SHA1_K0;
    } else if (i<40) {
      t = (b ^ c ^ d) + SHA1_K20;
    } else if (i<60) {
      t = ((b & c) | (d & (b | c))) + SHA1_K40;
    } else {
      t = (b ^ c ^ d) + SHA1_K60;
    }
    t+=rol32(a,5) + e + context->buffer[i&15];
    e=d;
    d=c;
    c=rol32(b,30);
    b=a;
    a=t;
  }
  context->state[0] += a;
  context->state[1] += b;
  context->state[2] += c;
  context->state[3] += d;
  context->state[4] += e;
}

void addUncounted(Sha1Context *context, uint8_t data) {
  ((uint8_t*)context->buffer)[context->bufferOffset ^ 3] = data;
  context->bufferOffset++;
  if (context->bufferOffset == BLOCK_LENGTH) {
    hashBlock(context);
    context->bufferOffset = 0;
  }
}

void write(void *contextPtr, uint8_t data) {
  Sha1Context *context = (Sha1Context*)contextPtr;
  ++context->byteCount;
  addUncounted(context, data);

  return;
}

void writeArray(void *contextPtr, uint8_t *buffer, uint8_t size){
  Sha1Context *context = (Sha1Context*)contextPtr;
    while (size--) {
    write(context, *buffer++);
    }
}

void pad(Sha1Context *context) {
  // Implement SHA-1 padding (fips180-2 ��5.1.1)

  // Pad with 0x80 followed by 0x00 until the end of the block
  addUncounted(context, 0x80);
  while (context->bufferOffset != 56) addUncounted(context, 0x00);

  // Append length in the last 8 bytes
  addUncounted(context, 0); // We're only using 32 bit lengths
  addUncounted(context, 0); // But SHA-1 supports 64 bit lengths
  addUncounted(context, 0); // So zero pad the top bits
  addUncounted(context, context->byteCount >> 29); // Shifting to multiply by 8
  addUncounted(context, context->byteCount >> 21); // as SHA-1 supports bitstreams as well as
  addUncounted(context, context->byteCount >> 13); // byte.
  addUncounted(context, context->byteCount >> 5);
  addUncounted(context, context->byteCount << 3);
}

uint8_t* result(void *contextPtr) {
  Sha1Context *context = (Sha1Context*)contextPtr;
  // Pad to complete the last block
  pad(context);

  // Swap byte order back
  uint8_t i;
  for (i=0; i<5; i++) {
    uint32_t a,b;
    a=context->state[i];
    b=a<<24;
    b|=(a<<8) & 0x00ff0000;
    b|=(a>>8) & 0x0000ff00;
    b|=a>>24;
    context->state[i]=b;
  }

  // Return pointer to hash (20 characters)
  return (uint8_t*)context->state;
}

#define HMAC_IPAD 0x36
#define HMAC_OPAD 0x5c

void initHmac(void *contextPtr, const uint8_t* key, uint8_t keyLength) {
  Sha1Context *context = (Sha1Context*)contextPtr;
  uint8_t i;
  memset(context->keyBuffer,0,BLOCK_LENGTH);
  if (keyLength > BLOCK_LENGTH) {
    // Hash long keys
    init(context);
    for (;keyLength--;) write(context, *key++);
    memcpy(context->keyBuffer,result(context),HASH_LENGTH);
  } else {
    // Block length keys are used as is
    memcpy(context->keyBuffer,key,keyLength);
  }
  // Start inner hash
  init(context);
  for (i=0; i<BLOCK_LENGTH; i++) {
    write(context, context->keyBuffer[i] ^ HMAC_IPAD);
  }
}

uint8_t* resultHmac(void *contextPtr) {
  Sha1Context *context = (Sha1Context*)contextPtr;
  uint8_t i;
  // Complete inner hash
  memcpy(context->innerHash,result(context),HASH_LENGTH);
  // Calculate outer hash
  init(context);
  for (i=0; i<BLOCK_LENGTH; i++) write(context, context->keyBuffer[i] ^ HMAC_OPAD);
  for (i=0; i<HASH_LENGTH; i++) write(context, context->innerHash[i]);
  return result(context);
}
