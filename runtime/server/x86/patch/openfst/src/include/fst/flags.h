// flags.h
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Copyright 2005-2010 Google, Inc.
// Author: riley@google.com (Michael Riley)
//
// \file
// Google-style flag handling declarations and inline definitions.

#ifndef FST_LIB_FLAGS_H__
#define FST_LIB_FLAGS_H__

#include <iostream>
#include <map>
#include <string>

using std::string;

#include <gflags/gflags.h>

// Declare flags that are defined elsewhere to avoid multiple definitions
DECLARE_bool(fst_verify_properties);
DECLARE_bool(fst_default_cache_gc);
DECLARE_int64(fst_default_cache_gc_limit);
DECLARE_bool(fst_align);
DECLARE_string(save_relabel_ipairs);
DECLARE_string(save_relabel_opairs);

// Declare flags for various FST tools
DECLARE_string(sort_type);
DECLARE_bool(closure_plus);
DECLARE_bool(acceptor);
DECLARE_string(arc_type);
DECLARE_string(fst_type);
DECLARE_string(isymbols);
DECLARE_string(osymbols);
DECLARE_string(ssymbols);
DECLARE_bool(keep_isymbols);
DECLARE_bool(keep_osymbols);
DECLARE_bool(keep_state_numbering);
DECLARE_bool(allow_negative_labels);

// Define macros that are missing from the original OpenFST
#define SET_FLAGS(usage, argc, argv, remove_flags) \
  gflags::SetUsageMessage(usage); \
  gflags::ParseCommandLineFlags(argc, argv, remove_flags)

inline void ShowUsage() {
  gflags::ShowUsageWithFlags(gflags::ProgramInvocationShortName());
}

#endif  // FST_LIB_FLAGS_H__
