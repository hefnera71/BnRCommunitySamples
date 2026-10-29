# Package code is MIT-licensed; see ../ED25519/LICENSE.txt.
import argparse
import os
import sys
# pip install pynacl (https://pypi.org/project/PyNaCl/)
from nacl.signing import SigningKey, VerifyKey
from nacl.exceptions import BadSignatureError
from nacl.encoding import HexEncoder

# Constants for the signature blocks
START_MARKER = b"--- BEGIN SIGNATURE ---\n"
END_MARKER = b"\n--- END  SIGNATURE ---\n"

def generate_keys(priv_path, pub_path):
    """Generate a new TweetNaCl key pair and save it as ASCII hex."""
    signing_key = SigningKey.generate()
    verify_key = signing_key.verify_key
    
    # Export keys as hex (ASCII)
    priv_hex = signing_key.encode(encoder=HexEncoder)
    pub_hex = verify_key.encode(encoder=HexEncoder)
    
    with open(priv_path, 'wb') as f:
        f.write(priv_hex)
    with open(pub_path, 'wb') as f:
        f.write(pub_hex)
        
    print(f"Key pair successfully generated as ASCII hex!")
    print(f" -> Private key (signing): {priv_path}")
    print(f" -> Public key (verification): {pub_path}")

def sign_file(file_path, key_path):
    """Sign a file using the loaded private hex key."""
    if not os.path.exists(key_path):
        print(f"Error: Private key '{key_path}' does not exist.", file=sys.stderr)
        sys.exit(1)
        
    # Load the private key from hex
    with open(key_path, 'rb') as f:
        priv_hex = f.read().strip()
    signing_key = SigningKey(priv_hex, encoder=HexEncoder)
    
    # Read the file contents
    with open(file_path, 'rb') as f:
        file_content = f.read()
        
    # If the file is already signed, skip the old header
    if file_content.startswith(START_MARKER):
        try:
            end_idx = file_content.index(END_MARKER)
            file_content = file_content[end_idx + len(END_MARKER):]
        except ValueError:
            pass 

    # Create the signature and format it as a hex string
    signature = signing_key.sign(file_content).signature
    signature_hex = signature.hex()
    
    # Overwrite the file with the required block at the beginning
    header = START_MARKER + signature_hex.encode('ascii') + END_MARKER
    with open(file_path, 'wb') as f:
        f.write(header)
        f.write(file_content)
        
    print(f"File '{file_path}' successfully signed.")

def verify_file(file_path, key_path):
    """Verify a file's signature using the public hex key."""
    if not os.path.exists(key_path):
        print(f"Error: Public key '{key_path}' does not exist.", file=sys.stderr)
        sys.exit(1)
        
    # Load the public key from hex
    with open(key_path, 'rb') as f:
        pub_hex = f.read().strip()
    verify_key = VerifyKey(pub_hex, encoder=HexEncoder)
    
    # Read the file contents
    with open(file_path, 'rb') as f:
        content = f.read()
        
    if not content.startswith(START_MARKER):
        print("[ERROR] ERROR: No valid signature marker found at the beginning of the file.")
        sys.exit(1)
        
    try:
        # Determine the block indices
        start_idx = len(START_MARKER)
        end_idx = content.index(END_MARKER, start_idx)
        
        # Extract the hex signature and convert it to bytes
        signature_hex = content[start_idx:end_idx].decode('utf-8').strip()
        signature = bytes.fromhex(signature_hex)
        
        # Separate the original contents after the marker
        original_content = content[end_idx + len(END_MARKER):]
        
        # Cryptographic verification
        verify_key.verify(original_content, signature)
        print("[OK] SUCCESS: The signature is VALID. The file has not been tampered with.")
        
    except (ValueError, BadSignatureError):
        print("[ERROR] CRITICAL: The signature is INVALID or the file has been tampered with!")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="TweetNaCl file signing tool (hex-based)")
    subparsers = parser.add_subparsers(dest="command", required=True, help="Available commands")
    
    # Subcommand: keygen
    keygen_parser = subparsers.add_parser("keygen", help="Generate a new key pair in hex format")
    keygen_parser.add_argument("--priv", default="secret.key", help="Path to the private key (default: secret.key)")
    keygen_parser.add_argument("--pub", default="public.key", help="Path to the public key (default: public.key)")
    
    # Subcommand: sign
    sign_parser = subparsers.add_parser("sign", help="Sign a file")
    sign_parser.add_argument("file", help="Path to the file to sign")
    sign_parser.add_argument("--key", default="secret.key", help="Path to the private key (default: secret.key)")
    
    # Subcommand: verify
    verify_parser = subparsers.add_parser("verify", help="Verify a file's signature")
    verify_parser.add_argument("file", help="Path to the file to verify")
    verify_parser.add_argument("--key", default="public.key", help="Path to the public key (default: public.key)")
    
    args = parser.parse_args()
    
    if args.command == "keygen":
        generate_keys(args.priv, args.pub)
    elif args.command == "sign":
        if not os.path.exists(args.file):
            print(f"Error: File '{args.file}' does not exist.", file=sys.stderr)
            sys.exit(1)
        sign_file(args.file, args.key)
    elif args.command == "verify":
        if not os.path.exists(args.file):
            print(f"Error: File '{args.file}' does not exist.", file=sys.stderr)
            sys.exit(1)
        verify_file(args.file, args.key)

if __name__ == "__main__":
    main()
