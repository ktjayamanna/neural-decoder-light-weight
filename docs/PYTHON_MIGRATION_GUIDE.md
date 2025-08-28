# Python Decoder Migration Guide

## What Changed
The decoder now supports **lazy composition** to reduce memory usage by 50-70% instead of loading massive TLG.fst files (20-30GB).

## Before vs After

### BEFORE: Only Traditional Approach
```python
# 5 parameters - loads entire TLG.fst (20-30GB) into memory
decode_resource = lm_decoder.DecodeResource(
    "/path/to/TLG.fst", "", "", "/path/to/words.txt", ""
)
```

### AFTER: Two Options

#### Option 1: Traditional (Unchanged)
```python
# Your existing code still works exactly the same
decode_resource = lm_decoder.DecodeResource(
    "/path/to/TLG.fst", "", "", "/path/to/words.txt", ""
)
```

#### Option 2: Lazy Composition (New - Memory Efficient)
```python
# 6 parameters - uses 50-70% less memory
decode_resource = lm_decoder.DecodeResource(
    "/path/to/T.fst",       # Small file (~38K)
    "/path/to/LG.fst",      # Medium file (~8.8GB)
    "", "", "/path/to/words.txt", ""
)
```

## Required Changes

### DecodeNumpy Now Requires 4 Parameters
```python
# BEFORE (might have worked)
lm_decoder.DecodeNumpy(decoder, logits)

# AFTER (required)
log_priors = np.zeros_like(logits)
lm_decoder.DecodeNumpy(decoder, log_priors, logits, 1.0)
```

## Migration Steps

1. **Your existing code still works** - no changes required
2. **To use lazy composition**: Use existing T.fst and LG.fst files (no preparation needed)
3. **Update constructor** to 6 parameters for memory savings

## Common Issues

### Wrong Parameter Count
```python
# ERROR
decode_resource = lm_decoder.DecodeResource(t_path, lg_path, dict_path)

# CORRECT - always use all parameters
decode_resource = lm_decoder.DecodeResource(t_path, lg_path, "", "", dict_path, "")
```

### DecodeNumpy Arguments
```python
# ERROR
lm_decoder.DecodeNumpy(decoder, logits)

# CORRECT
log_priors = np.zeros_like(logits)
lm_decoder.DecodeNumpy(decoder, log_priors, logits, 1.0)
```

## When to Use Each

- **Traditional**: When memory isn't a concern, maximum speed needed
- **Lazy Composition**: When memory is limited, want 50-70% memory reduction
