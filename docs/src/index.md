# ROOTprefs

## Introduction

The `ROOTprefs`  package is used to set shared library installation preferences for [ROOT.jl](https://github.com/JuliaHEP/ROOT.jl). Preferences must be set before the `ROOT` module is imported, which is why methods for setting them are provided in a separate package.

`ROOT.jl` offers a Julia interface to the C++ [ROOT](https://root.cern) framework. This package requires the C++ ROOT shared libraries and a shared library that provides the Julia bindings based on [CxxWrap](https://github.com/JuliaInterop/CxxWrap.jl).

The `ROOT_jll` and `ROOT_julia_jll` packages, which are installed by the Julia package manager when adding `ROOT.jl`, provide the shared libraries for Linux. An alternative option, currently the only one available on macOS, is to use a standard ROOT C++ software installation (not `ROOT_jll`). In this case, the C++-Julia interface shared library is built on-the-fly the first time the ROOT module is imported.

The `ROOTprefs` Julia package provides the methods to customize how the C++ shared libraries are provided. In particular, see the [`set_use_root_jll(enable=true)`](@ref) and [`set_ROOTSYS(path=nothing)`](@ref) methods. Preferences are stored in the `LocalPreferences.toml` file of the active Julia project.

## Usage

### The main switch

To use shared libraries from the `jll` packages, if available for your platform, call [`set_use_root_jll()`](@ref). To use externally installed ROOT software and compile on the fly the library for the Julia bindings, call `use_root_jll(false)(@ref)'.

### Specifying external ROOT installation location

The external ROOT installation location, also known as `ROOTSYS`, can be set by calling [`set_ROOTSYS(path)`](@ref). When not set, if the `ROOTSYS` environment variable is defined and points to a ROOT installation with a suitable version or a ROOT installation with a suitable version is accessible from the environement (executables in the `PATH`), then the location will be set according at first import of the `ROOT` package.

## Functions

The complete set of methods provided by `ROOTprefs` follows.

```@meta
CurrentModule = ROOTprefs
```

```@autodocs
Modules = [ ROOTprefs ]
Order   = [ :function, :module ]
```

## Index
```@index
```

