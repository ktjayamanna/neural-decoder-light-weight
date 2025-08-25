// Copyright (c) 2021 Mobvoi Inc (Binbin Zhang)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef UTILS_LOG_H_
#define UTILS_LOG_H_

// Custom logging wrapper to avoid conflicts between OpenFST and glog
#ifndef UTILS_LOG_H_
#define UTILS_LOG_H_

// This header manages conflicts between glog (used by PyTorch) and OpenFST logging

// First, check if glog is already included (via PyTorch)
#ifdef GLOG_LOGGING_H_
// glog is already included, we need to be careful about conflicts

// Save glog's FLAGS_v if it exists
#ifdef FLAGS_v
#define SAVED_GLOG_FLAGS_v FLAGS_v
#undef FLAGS_v
#endif

// Undefine glog's DCHECK macros temporarily
#ifdef DCHECK
#undef DCHECK
#endif
#ifdef DCHECK_EQ
#undef DCHECK_EQ
#endif
#ifdef DCHECK_NE
#undef DCHECK_NE
#endif
#ifdef DCHECK_LE
#undef DCHECK_LE
#endif
#ifdef DCHECK_LT
#undef DCHECK_LT
#endif
#ifdef DCHECK_GE
#undef DCHECK_GE
#endif
#ifdef DCHECK_GT
#undef DCHECK_GT
#endif

// Now include OpenFST log
#include "fst/log.h"

// Restore glog's FLAGS_v if it was saved
#ifdef SAVED_GLOG_FLAGS_v
#define FLAGS_v SAVED_GLOG_FLAGS_v
#undef SAVED_GLOG_FLAGS_v
#endif

#else
// glog is not included yet, just include OpenFST log
#include "fst/log.h"
#endif

#endif  // UTILS_LOG_H_

#endif  // UTILS_LOG_H_
