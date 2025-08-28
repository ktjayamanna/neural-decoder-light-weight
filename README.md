# speechBCI Language Model Decoder

This is the repository for the speechBCI language model decoder. The code is based on [WeNet](https://github.com/wenet-e2e/wenet) and [Kaldi](https://github.com/kaldi-asr/kaldi).

## Build Instructions

### Dependencies
```
CMake >= 3.14
gcc >= 10.1
pytorch==1.13.1
```

### Step 1: Build SRILM
```bash
cd srilm-1.7.3
export SRILM=$PWD
make -j8 MAKE_PIC=yes World && make -j8 cleanest
```

### Step 2: Build C++ Libraries
```bash
cd runtime/server/x86
mkdir build && cd build
cmake .
make -j8
```

### Step 3: Install Python Module
```bash
cd runtime/server/x86
python setup.py install
```

## Usage

### Basic Usage
```python
import lm_decoder
```

### Lazy Composition (Memory Efficient)

The decoder now supports lazy composition to reduce memory usage by avoiding loading large TLG.fst files (≈27 GB). Instead, it uses separate TL.fst and G.fst files with on-the-fly composition.

#### Step 1: Prepare FSTs
Ensure your model directory contains T.fst, L.fst, G.fst, and words.txt.

#### Step 2: Create TL.fst
```bash
./scripts/bash_scripts/precompose_tl.sh /path/to/model/directory
```

#### Step 3: Use Lazy Composition
```python
import lm_decoder

# Create decode options
decode_opts = lm_decoder.DecodeOptions(7000, 200, 17.0, 8.0, 1.0, 0.98, 0.0, 10)

# Use lazy composition with separate TL.fst and G.fst
decode_resource = lm_decoder.DecodeResource(
    "/path/to/TL.fst",      # tl_fst_path
    "/path/to/G.fst",       # g_fst_path
    "",                     # lm_fst_path
    "",                     # rescore_lm_fst_path
    "/path/to/words.txt",   # dict_path
    ""                      # unit_path
)

decoder = lm_decoder.BrainSpeechDecoder(decode_resource, decode_opts)

# Use decoder normally
lm_decoder.DecodeNumpy(decoder, logits)
decoder.FinishDecoding()
results = decoder.result()
```

#### Traditional Usage (Backward Compatible)
```python
# Traditional approach with pre-composed TLG.fst
decode_resource = lm_decoder.DecodeResource(
    "/path/to/TLG.fst",     # fst_path
    "",                     # lm_fst_path
    "",                     # rescore_lm_fst_path
    "/path/to/words.txt",   # dict_path
    ""                      # unit_path
)
```

### Command-Line Usage

#### Lazy Composition
```bash
./brain_speech_decoder_main \
    --tl_fst_path /path/to/TL.fst \
    --g_fst_path /path/to/G.fst \
    --dict_path /path/to/words.txt \
    --data_path /path/to/input/data
```

#### Traditional Approach
```bash
./brain_speech_decoder_main \
    --fst_path /path/to/TLG.fst \
    --dict_path /path/to/words.txt \
    --data_path /path/to/input/data
```


