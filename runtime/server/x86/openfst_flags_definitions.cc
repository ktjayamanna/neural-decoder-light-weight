// OpenFST flags definitions to resolve linking issues
// This file provides definitions for OpenFST flags that are declared but not defined

#include <string>

// Define all the OpenFST flags that are declared in the headers
bool FLAGS_fst_error_fatal = false;
std::string FLAGS_fst_weight_parentheses = "";
std::string FLAGS_fst_weight_separator = ",";
std::string FLAGS_fst_field_separator = "\t";
std::string FLAGS_save_relabel_ipairs = "";
std::string FLAGS_save_relabel_opairs = "";
bool FLAGS_fst_default_cache_gc = false;
bool FLAGS_fst_verify_properties = false;
bool FLAGS_fst_compat_symbols = true;
bool FLAGS_fst_align = false;

// Define FLAGS_v in the fLI namespace (this seems to be how it's referenced in the linker errors)
namespace fLI {
    int FLAGS_v = 0;
}

// Also define it in the global namespace for compatibility
int FLAGS_v = 0;
