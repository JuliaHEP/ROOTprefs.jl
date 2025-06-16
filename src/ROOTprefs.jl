"""
  `ROOTprefs`

Main module of the `ROOTprefs` Julia package.
"""
module ROOTprefs

export use_root_jll!, is_root_jll_used, set_ROOTSYS!, get_ROOTSYS, check_root_version, is_root_version_checked, clean_after_build!, is_clean_after_build_enabled

import Preferences
using TOML

preference_file() = joinpath(dirname(Base.active_project()), "LocalPreferences.toml")

# `_set_preference(preference::String, value)`
#
# Add a preference to the LocalPreferences.toml file of the active project.
# In the special case where `nothing` is passed as `value`, the preference is 
# deleted from the file (no effect if it is missing, apart from rewriting the file
# with sorted preferences).

function _set_preference(preference::String, value)
    prefs = if isfile(preference_file())
        TOML.parsefile(preference_file())
    else
        Dict{String,Any}()
    end

    if !haskey(prefs, "ROOT") || !isa(prefs["ROOT"],Dict)
        prefs["ROOT"] = Dict{String, Any}()
    end
   
    if isnothing(value) #nothing value used to request the preference deletion
        delete!(prefs["ROOT"], preference)
    else 
        prefs["ROOT"][preference] = value
    end

    open(preference_file(), "w") do f
        TOML.print(f, prefs, sorted=true)
    end
end

function _load_preference_from_toml(preference::String, default)
    prefs = if isfile(preference_file())
        TOML.parsefile(preference_file())
    else
        Dict{String,Any}()
    end

    if !haskey(prefs, "ROOT") || !isa(prefs["ROOT"],Dict)
        return default
    end
    
    return get(prefs["ROOT"], preference, default)
end

function _load_preference(preference::String, default)
    val = try
        # We first use the method from Preferences that handles precompilation
        # dependency and stacked environemnt.  This will fail if the ROOT package is
        # not installed.
        Preferences.load_preference("ROOT", preference)
    catch
        nothing
    end
    
    if isnothing(val)
        # The preference is not set or ROOT package is not install. Read it
        # directly from the LocalPreference.toml file, if it exists.
        val = _load_preference_from_toml(preference, default)
    end
    val
end

"""
    `use_root_jll!(enable=true)`

   Enable or disable the jll mode (default when the platform is supported by jll).

   The Julia ROOT package needs the C++ ROOT libraries to run. Prebuilt ROOT libraries are provided in the [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) repository as Julia packages. In the jll mode, the native package manager of Julia installs automatically the ROOT libraries on the machine. This mode is currently supported for Linux on x86 architecture.

   When disabled, or if the platform is not supported by the jll mode, the C++ libraries must be installed on the machine before installing the Julia ROOT package and the ROOTSYS preference must be set using [`set_ROOTSYS()`](@ref) function.
"""
function use_root_jll!(enable=true; nowarn=false)
    #old = load_preference("ROOT", "use_root_jll")
    old = is_root_jll_used()
    
    #set_preferences!("ROOT", "use_root_jll" => enable)
    _set_preference("use_root_jll", enable)
    
    if old != enable && !nowarn
        if haskey(Base.loaded_modules, Base.PkgId(Base.UUID("1706fdcc-8426-44f1-a283-5be479e9517c"), "ROOT"))
            println(stderr, "BEWARE: the preference change will be effective only after restart of Julia.")
        end
    end
end
"""
    is_root_jll_used()

   Retrieve the jll mode setting. Return `true` if enable, `false` if disables.

@see [`use_root_jll!()`](@ref).
"""
function is_root_jll_used()
    #    load_preference("ROOT", "use_root_jll", true)
    _load_preference("use_root_jll", true)
end                 

"""
    `set_ROOTSYS!(path=nothing)`

Set the path of the ROOT C++ libraries installation, also known as ROOTSYS, when it is handle by the Julia package manager with the _jll packages (see [`use_root_jll(enable)`](@ref).

The Julia ROOT package will use the command `\$ROOTSYS/bin/root-config`, where `\$ROOTSYS` is the path set by this function, to locate the ROOT C++ libraries (typically in `\$ROOTSYS/lib`).

When called without argument and the ROOTSYS environment variable is set, its value will be used. In case this variable is not set, the `root-config` command will be searched in the system binary paths (defined by the PATH environment variable) and ROOTSYS preference will be set according.

By default, the presence of the `root-config` command in `\$ROOTSYS/bin/root-config` is checked (except if `path` is the empty string). Pass `nocheck=true` as argument to disable the check.

!!! warning "Each Julia ROOT package version will require a specific release of the C++ ROOT libraries due to dependency on release-dependent C++ API details."
Before installing a new version, call `use_root_jll(false)` to disable the ROOT_jll mode, and execute `try import ROOT; catch; end`. This will tell you the supported versions if possibly installed one is not supported.
"""
function set_ROOTSYS!(path=nothing; nocheck=false)
    old = get_ROOTSYS()
    
    if isnothing(path) && haskey(ENV, "ROOTSYS")
        path = ENV["ROOTSYS"]
    elseif isnothing(path)
        #look for root-config in PATH list
        paths = joinpath.(split(ENV["PATH"], ":"), "root-config") |> filter(Sys.isexecutable)
        if length(paths) == 0
            error("ROOTSYS environment variable not set and command root-config command not found.")
        else
            path = paths[1] |> dirname |> dirname
        end
    end

    if !nocheck && !isempty(path)
        rootconfig = joinpath(path, "bin", "root-config")
        isfile(rootconfig) || error("$rootconfig not found.")
	Sys.isexecutable(rootconfig) || error("$rootconfig is not executable.")
    end
    
    #set_preferences("ROOT", "ROOTSYS" => path)
    _set_preference("ROOTSYS", path)
    
    if !isempty(path)
        print("ROOT version: ")
        try
            run(`"$path/bin/root-config" --version`)
        catch
            if nocheck
                println("unknow (root-config command not found)")
            else
                rethrow()
            end
        end
    end

    println("ROOTSYS path: ", path)
    
    if old != path && haskey(Base.loaded_modules, Base.PkgId(Base.UUID("1706fdcc-8426-44f1-a283-5be479e9517c"), "ROOT"))
        println(stderr, "BEWARE: the preference change will be effective only after restart of Julia.")
    end
end

"""
    get_ROOTSYS()
    
Retrieve the ROOTSYS preference (see [`set_ROOTSYS()`](@ref).
    """
function get_ROOTSYS()
    _load_preference("ROOTSYS", "")
end

"""
   check_root_version(enable=true)

Enable or disable the ROOT C++ library version check for the non-jll mode. By default, the Julia ROOT package checks that the version of the ROOT C++ libraries set by [`set_ROOTSYS()`](@ref) matches with the version(s) it was validated for and throw an exception on `import` if it does not. Use this function to disable (or re-enable) the check.
"""
function check_root_version(enable=true)
    #    set_preferences("ROOT", "check_root_version" => enable)
    _set_preference("check_root_version", enable)
end

"""
   is_root_version_checked()

Retrieve the ROOT version check setting (see [`check_root_version!()`](@ref).
"""
function is_root_version_checked()
    _load_preference("check_root_version", true)
end


"""
   clean_after_build(enable=true)

Enable or disable the deletion of the intermediate build products after the shared library is built (the default).
"""
function clean_after_build!(enable=true)
    _set_preference("clean_after_build", enable)
end

"""
   clean_after_build(enable=true)

Retrieve the clean-after-build setting. See [`clean_after_build()`](@ref).
"""
function is_clean_after_build_enabled()
    _load_preference("clean_after_build", true)
end

end
