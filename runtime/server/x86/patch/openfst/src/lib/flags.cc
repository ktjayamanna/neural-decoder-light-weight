// flags.cc

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
// Google-style flag handling definitions.

#include <fst/compat.h>
#include <fst/flags.h>

// Simplified flag handling - delegate to gflags
void SetFlags(const char *usage, int *argc, char ***argv, bool remove_flags,
              const char *src) {
  // Use gflags for flag parsing
  gflags::SetUsageMessage(usage);
  gflags::ParseCommandLineFlags(argc, argv, remove_flags);
}

void ShowUsage(bool long_usage) {
  gflags::ShowUsageWithFlags(gflags::ProgramInvocationShortName());
}
