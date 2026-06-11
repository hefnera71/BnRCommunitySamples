// Copyright (c) 2026 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details

#include "Base32.h"

void base32_encode(const char *input, unsigned int input_len, char *output) {
	// RFC 4648 Base32 alphabet
	const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    
	int buffer = 0;
	int next_shift = 0;
	int out_idx = 0;

	for (int i = 0; i < input_len; i++) {
		buffer = (buffer << 8) | (input[i] & 0xFF);
		next_shift += 8;

		while (next_shift >= 5) {
			next_shift -= 5;
			output[out_idx++] = lookup[(buffer >> next_shift) & 0x1F];
		}
	}

	// if bits left, fill em with 0
	if (next_shift > 0) {
		buffer <<= (5 - next_shift);
		output[out_idx++] = lookup[buffer & 0x1F];
	}

	// padding with '='
	while (out_idx % 8 != 0) {
		output[out_idx++] = '=';
	}
	
	// str end
	output[out_idx] = '\0';
}
