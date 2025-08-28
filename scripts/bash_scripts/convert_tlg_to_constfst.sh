#!/bin/bash
# Simple script to convert TLG FST models to ConstFst format

# Get the script directory to find workspace paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Add local OpenFST installation to PATH if it exists
LOCAL_INSTALL_DIR="$WORKSPACE_DIR/local"
if [ -d "$LOCAL_INSTALL_DIR/bin" ]; then
    export PATH="$LOCAL_INSTALL_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$LOCAL_INSTALL_DIR/lib:$LD_LIBRARY_PATH"
fi

# Function to check if OpenFST is installed
check_openfst() {
    if command -v fstconvert >/dev/null 2>&1; then
        echo "✓ OpenFST is already installed"
        fstconvert --version 2>/dev/null || echo "  (version info not available)"
        return 0
    else
        echo "✗ OpenFST not found"
        return 1
    fi
}

# Function to install OpenFST
install_openfst() {
    echo "Installing OpenFST..."

    # Check if we have required build tools
    if ! command -v make >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1; then
        echo "Error: Build tools (make, g++) are required but not found."
        echo "Please install build dependencies manually:"
        echo "  Ubuntu/Debian: apt-get install build-essential"
        echo "  CentOS/RHEL: yum groupinstall 'Development Tools'"
        echo "  macOS: xcode-select --install"
        exit 1
    fi

    # Create temporary directory for installation
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Use local OpenFST tar.gz file
    OPENFST_VERSION="1.8.4"

    # Use the workspace directory already calculated
    LOCAL_OPENFST_FILE="$WORKSPACE_DIR/data/installation/openfst-${OPENFST_VERSION}.tar.gz"

    # Check if local file exists, otherwise download
    if [ -f "$LOCAL_OPENFST_FILE" ]; then
        echo "Using local OpenFST ${OPENFST_VERSION} file: $LOCAL_OPENFST_FILE"
        cp "$LOCAL_OPENFST_FILE" .
    else
        echo "Local file not found, downloading OpenFST ${OPENFST_VERSION}..."
        OPENFST_URL="https://www.openfst.org/twiki/pub/FST/FstDownload/openfst-${OPENFST_VERSION}.tar.gz"
        if ! wget "$OPENFST_URL"; then
            echo "Error: Failed to download OpenFST"
            cd - >/dev/null
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    fi

    # Extract and compile
    echo "Extracting OpenFST..."
    tar -xzf "openfst-${OPENFST_VERSION}.tar.gz"
    cd "openfst-${OPENFST_VERSION}"

    # Create local installation directory
    LOCAL_INSTALL_DIR="$WORKSPACE_DIR/local"
    mkdir -p "$LOCAL_INSTALL_DIR"

    echo "Configuring OpenFST for local installation..."
    if ! ./configure --prefix="$LOCAL_INSTALL_DIR"; then
        echo "Error: Failed to configure OpenFST"
        cd - >/dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    echo "Compiling OpenFST (this may take several minutes)..."
    if ! make -j$(nproc 2>/dev/null || echo 4); then
        echo "Error: Failed to compile OpenFST"
        cd - >/dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    echo "Installing OpenFST to local directory..."
    if ! make install; then
        echo "Error: Failed to install OpenFST"
        cd - >/dev/null
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Add local bin directory to PATH for this session
    export PATH="$LOCAL_INSTALL_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$LOCAL_INSTALL_DIR/lib:$LD_LIBRARY_PATH"

    # Clean up
    cd - >/dev/null
    rm -rf "$TEMP_DIR"

    echo "✓ OpenFST installation completed successfully!"
}

# Check for OpenFST installation
echo "Checking for OpenFST installation..."
if ! check_openfst; then
    echo ""
    read -p "OpenFST is required but not installed. Install it now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_openfst
        echo ""
        echo "Verifying installation..."
        if ! check_openfst; then
            echo "Error: OpenFST installation failed or is not in PATH"
            echo "Local installation directory: $LOCAL_INSTALL_DIR"
            echo "You may need to restart your shell or run the script again"
            exit 1
        fi
    else
        echo "OpenFST is required to run this script. Please install it manually."
        echo "Visit: https://www.openfst.org/twiki/bin/view/FST/FstDownload"
        exit 1
    fi
fi

echo ""

# Set the model directory path
DEFAULT_MODEL_DIR="$WORKSPACE_DIR/data/models/three_gram_lm"

# Allow override with command line argument if provided
if [ $# -eq 1 ]; then
    MODEL_DIR="$1"
    echo "Using custom model directory: $MODEL_DIR"
else
    MODEL_DIR="$DEFAULT_MODEL_DIR"
    echo "Using default model directory: $MODEL_DIR"
fi

if [ ! -d "$MODEL_DIR" ]; then
    echo "Error: Directory $MODEL_DIR does not exist"
    exit 1
fi

echo "Converting FST models in $MODEL_DIR to ConstFst format..."
echo "Note: Original files will be deleted after successful conversion to save disk space"
echo ""

# Check available disk space before starting
if command -v df >/dev/null 2>&1; then
    echo "Current disk usage for $MODEL_DIR:"
    df -h "$MODEL_DIR" 2>/dev/null || df -h .
    echo ""
fi

# Count total FST files to process
fst_count=0
for fst_file in "$MODEL_DIR"/*.fst; do
    [ -f "$fst_file" ] && ((fst_count++))
done

if [ $fst_count -eq 0 ]; then
    echo "No .fst files found in $MODEL_DIR"
    exit 1
fi

echo "Found $fst_count FST file(s) to convert"
echo ""

# Convert each FST file to ConstFst
current_file=0
for fst_file in "$MODEL_DIR"/*.fst; do
    if [ -f "$fst_file" ]; then
        ((current_file++))
        basename=$(basename "$fst_file" .fst)
        output_file="$MODEL_DIR/${basename}_const.fst"

        echo "[$current_file/$fst_count] Converting $basename.fst -> ${basename}_const.fst"

        # Get file size before conversion
        if command -v du >/dev/null 2>&1; then
            original_size=$(du -h "$fst_file" | cut -f1)
            echo "  Original file size: $original_size"
        fi

        # Use OpenFst's fstconvert to convert to ConstFst
        if fstconvert --fst_type=const "$fst_file" "$output_file"; then
            # Get new file size
            if command -v du >/dev/null 2>&1; then
                new_size=$(du -h "$output_file" | cut -f1)
                echo "  ✓ Successfully converted (new size: $new_size)"
            else
                echo "  ✓ Successfully converted $basename.fst"
            fi

            # Delete the old model file to save disk space
            if rm "$fst_file"; then
                echo "  ✓ Deleted original file to save disk space"
            else
                echo "  ⚠ Warning: Could not delete original file $basename.fst"
            fi
        else
            echo "  ✗ Failed to convert $basename.fst"
            # Remove the failed output file if it exists
            if [ -f "$output_file" ]; then
                rm "$output_file"
                echo "  ✓ Cleaned up failed conversion file"
            fi
        fi
        echo ""
    fi
done

echo "Conversion complete!"
echo ""

# Show final disk usage
if command -v df >/dev/null 2>&1; then
    echo "Final disk usage for $MODEL_DIR:"
    df -h "$MODEL_DIR" 2>/dev/null || df -h .
    echo ""
fi

# List the converted files
echo "Converted files (original files deleted to save disk space):"
for const_file in "$MODEL_DIR"/*_const.fst; do
    if [ -f "$const_file" ]; then
        basename=$(basename "$const_file")
        if command -v du >/dev/null 2>&1; then
            size=$(du -h "$const_file" | cut -f1)
            echo "  ✓ $basename ($size)"
        else
            echo "  ✓ $basename"
        fi
    fi
done

echo ""
echo "Usage: Use the new optimized models with '_const' suffix in your applications."
echo "These ConstFst models are more memory-efficient and faster to load."
