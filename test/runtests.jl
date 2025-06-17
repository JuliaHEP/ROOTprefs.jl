# This script is run by Pkg.test("ROOTprefs").
#
# It can also be run in the test directory environment:
#
# cd test
# julia --project=.
# julia> ]instantiate
# julia> include("runtest.jl")
#
# The TestEnv package can be used to run in a clean environment as Phg.test(...)
# does.

push!(LOAD_PATH, joinpath(@__DIR__, ".."))

using Test
import ROOT_jll

using ROOTprefs

# clean-up for test of default value in case of run in the test directory environment
isfile(joinpath(@__DIR__, "LocalPreferences.toml")) && rm(joinpath(@__DIR__, "LocalPreferences.toml") )

rootsys = ROOT_jll.root_path |> dirname |> dirname

@testset begin
    #Test default settings
    @test get_use_root_jll()
    @test get_check_root_version()
    @test get_ROOTSYS() == ""

    #Test preference change
    set_use_root_jll(false)
    @test !get_use_root_jll()
    set_check_root_version(false)
    @test !get_check_root_version()
    set_ROOTSYS(rootsys)
    @test get_ROOTSYS() == rootsys

    #Test extended features of set_ROOTSYS()
    
    #  1. use of ROOTSYS environment variable
    set_ROOTSYS("")
    withenv("ROOTSYS" => rootsys) do
        set_ROOTSYS()
        @test get_ROOTSYS() == rootsys
    end

    #  2. Search of root-config in PATH
    set_ROOTSYS("")
    @test get_ROOTSYS() == ""
    withenv("PATH" => join(vcat(ENV["PATH"], [joinpath(rootsys, "bin")]), ":")) do
        set_ROOTSYS()
        @test get_ROOTSYS() == rootsys

        #  ROOTSYS must take precedence on root-config search
        withenv("ROOTSYS" => "from_ROOTSYS") do
            set_ROOTSYS(nocheck=true)
            @test get_ROOTSYS() == "from_ROOTSYS"
        end

    end
    
    #   Test nocheck argument of set_ROOTSYS()
    set_ROOTSYS("foo", nocheck=true)
    @test get_ROOTSYS() == "foo"
    withenv("PATH" => "") do
        @test_throws ErrorException set_ROOTSYS()
        @test get_ROOTSYS() == "foo"
    end
    withenv("ROOTSYS" => "from_ROOTSYS") do
        @test_throws ErrorException set_ROOTSYS()
        set_ROOTSYS(nocheck=true)
        @test get_ROOTSYS() == "from_ROOTSYS"
    end
end
