#ifndef FST_LIB_MAIN_H__
#define FST_LIB_MAIN_H__

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

#include <gflags/gflags.h>
#include <glog/logging.h>

#include <fst/extensions/far/farscript.h>
#include <fst/extensions/far/getters.h>
#include <fst/script/arg-packs.h>
#include <fst/script/fst-class.h>
#include <fst/script/text-io.h>

DECLARE_string(fst_type);
DECLARE_bool(fst_verify);
DECLARE_string(arc_type);
DECLARE_string(fst_align);
DECLARE_bool(fst_error_fatal);
DECLARE_string(save_relabel_ipairs);
DECLARE_string(save_relabel_opairs);

using std::string;

// Define macros that are missing from the original OpenFST
#define SET_FLAGS(usage, argc, argv, remove_flags) \
  gflags::SetUsageMessage(usage); \
  gflags::ParseCommandLineFlags(argc, argv, remove_flags)

inline void ShowUsage() {
  gflags::ShowUsageWithFlags(gflags::ProgramInvocationShortName());
}

#endif  // FST_LIB_MAIN_H__
