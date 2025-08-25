// Logging compatibility header to resolve conflicts between glog and OpenFST
#ifndef UTILS_LOGGING_COMPATIBILITY_H_
#define UTILS_LOGGING_COMPATIBILITY_H_

// This header must be included before any OpenFST or PyTorch headers
// to prevent symbol conflicts between glog and OpenFST logging systems

// Include glog first to establish its definitions
#include <glog/logging.h>

// Prevent OpenFST's log.h from being included by defining its include guard
#define FST_LOG_H_

// Define OpenFST's expected macros using glog's implementations
#ifndef DECLARE_int32
#define DECLARE_int32(name) // Do nothing, glog already declares FLAGS_v
#endif

#ifndef DECLARE_string
#define DECLARE_string(name) // Do nothing
#endif

// Make sure CHECK works (glog already defines this)
#ifndef CHECK
#define CHECK(condition) CHECK(condition)
#endif

// Define VLOG using glog's VLOG
#ifndef VLOG
#define VLOG(level) VLOG(level)
#endif

#endif  // UTILS_LOGGING_COMPATIBILITY_H_
