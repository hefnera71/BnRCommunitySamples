// Copyright (c) 2026 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
#ifndef BASE32_H
#define BASE32_H

#ifdef __cplusplus
extern "C" {
#endif

void base32_encode(const char *input, unsigned int input_len, char *output);

#ifdef __cplusplus
}
#endif

#endif /* BASE32_H */
