# C++ Developer Guide: Lazy Composition Changes

## What Changed
Added lazy composition support to reduce memory usage by 50-70% instead of loading large TLG.fst files (20-30GB).

## Key Architecture Changes

### DecodeResource - New Members and Constructor
```cpp
// BEFORE: Single FST
struct DecodeResource {
  std::shared_ptr<fst::Fst<fst::StdArc>> fst = nullptr;  // TLG.fst only
};

// AFTER: Multiple FSTs + new constructor
struct DecodeResource {
  std::shared_ptr<fst::Fst<fst::StdArc>> fst = nullptr;      // Traditional TLG.fst
  std::shared_ptr<fst::Fst<fst::StdArc>> tl_fst = nullptr;   // NEW: TL FST
  std::shared_ptr<fst::Fst<fst::StdArc>> g_fst = nullptr;    // NEW: G FST

  // NEW: 6-parameter constructor for lazy composition
  DecodeResource(const string &tl_fst_path, const string &g_fst_path, ...);
};
```

### CtcWfstBeamSearch - Major Changes
```cpp
// BEFORE: Direct decoder member
class CtcWfstBeamSearch {
private:
  kaldi::LatticeFasterOnlineDecoder decoder_;  // Direct member
};

// AFTER: Pointer + lazy composition support
class CtcWfstBeamSearch {
public:
  // NEW: Lazy composition constructor
  CtcWfstBeamSearch(const fst::Fst<fst::StdArc>& tl_fst,
                    const fst::Fst<fst::StdArc>& g_fst,
                    CtcWfstBeamSearchOptions& opts);
private:
  std::unique_ptr<kaldi::LatticeFasterOnlineDecoder> decoder_;  // Now pointer
  std::unique_ptr<fst::ComposeFst<fst::StdArc>> composed_fst_;  // NEW: Lazy composition
  bool use_lazy_composition_ = false;                           // NEW: Mode flag
};
```

### BrainSpeechDecoder - Intelligent Selection
```cpp
// BEFORE: Simple FST check
if (nullptr == fst_) {
  searcher_.reset(new CtcPrefixBeamSearch(...));
} else {
  searcher_.reset(new CtcWfstBeamSearch(*fst_, ...));
}

// AFTER: Checks for lazy composition first
if (resource->tl_fst != nullptr && resource->g_fst != nullptr) {
  searcher_.reset(new CtcWfstBeamSearch(*resource->tl_fst, *resource->g_fst, ...));  // NEW
} else if (nullptr == fst_) {
  searcher_.reset(new CtcPrefixBeamSearch(...));
} else {
  searcher_.reset(new CtcWfstBeamSearch(*fst_, ...));  // Traditional
}
```

## Critical Implementation Changes

### Decoder Member Access Changed
```cpp
// BEFORE: Direct member access
decoder_.InitDecoding();
decoder_.AdvanceDecoding(&decodable_, 1);

// AFTER: Pointer access (IMPORTANT for extensions)
decoder_->InitDecoding();
decoder_->AdvanceDecoding(&decodable_, 1);
```

### Command-Line Interface
```cpp
// NEW flags
DEFINE_string(tl_fst_path, "", "TL fst path for lazy composition");
DEFINE_string(g_fst_path, "", "G fst path for lazy composition");

// NEW resource creation logic
if (!FLAGS_tl_fst_path.empty() && !FLAGS_g_fst_path.empty()) {
  decode_resource = std::make_shared<wenet::DecodeResource>(
      FLAGS_tl_fst_path, FLAGS_g_fst_path, ...);  // Lazy composition
} else {
  decode_resource = std::make_shared<wenet::DecodeResource>(
      FLAGS_fst_path, ...);                       // Traditional
}
```

## Migration for Existing Code

### Your Existing Code Still Works
```cpp
// No changes needed - backward compatible
auto resource = std::make_shared<DecodeResource>(tlg_path, "", "", dict_path, "");
```

### If Extending CtcWfstBeamSearch
**CRITICAL**: `decoder_` is now `unique_ptr` - change all access from `.` to `->`

### If Adding FST Operations
- Check `use_lazy_composition_` flag to determine FST structure
- Access composed FST through `composed_fst_` when in lazy mode

## Memory Impact
- **Traditional**: Loads 20-30GB TLG.fst immediately
- **Lazy Composition**: Loads TL.fst (~100MB) + G.fst (~5-10GB), composes on-demand
- **Result**: 50-70% memory reduction
