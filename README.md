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
```python
import lm_decoder
```
