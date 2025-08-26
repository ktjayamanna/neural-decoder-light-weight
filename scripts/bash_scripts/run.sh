#!/bin/bash

# Neural Decoder Build and Install Script
# Simple script to build and install the lm_decoder Python module

set -e  # Exit on any error

echo "Building and installing neural decoder..."

# Navigate to the decoder directory
cd runtime/server/x86

echo "Running setup.py install --user..."
python3 setup.py install --user

echo "Neural decoder installed successfully!"
echo ""
echo "You can now import lm_decoder in Python:"
echo "  import lm_decoder"
