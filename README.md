# ROOTprefs.jl

[![doc-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliahep.github.io/ROOTprefs.jl/dev/)

This Julia package is used to set shared library installation preferences for [ROOT.jl](https://github.com/JuliaHEP/ROOT.jl). Preferences must be set before the `ROOT` module is imported, which is why methods for setting them are provided in a separate package.

`ROOT.jl` offers a Julia interface to the C++ [ROOT](https://root.cern) framework. This package requires the C++ ROOT shared libraries and a shared library that provides the Julia bindings based on [CxxWrap](https://github.com/JuliaInterop/CxxWrap.jl).

The `ROOT_jll` and `ROOT_julia_jll` packages, which are installed by the Julia package manager when adding `ROOT.jl`, provide the shared libraries for Linux. An alternative option, currently the only one available on macOS, is to use a standard ROOT C++ software installation (not `ROOT_jll`). In this case, the C++-Julia interface shared library is built on-the-fly the first time the ROOT module is imported.

The `ROOTprefs` Julia package offers methods to customize how the C++ shared libraries are provided. In particular, see the `use_root_jll!(enable=true)` and `set_ROOTSYS!(ROOTSYS)` methods. Preferences are stored in the `LocalPreferences.toml` file of the active Julia project.

