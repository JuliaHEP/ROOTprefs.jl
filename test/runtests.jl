import Pkg

Pkg.activate(temp=true)
Pkg.add("Test")
Pkg.add("ROOT_jll")

using Test
import ROOT_jll

#add tested project in LOAD_PATH to import it
push!(LOAD_PATH, dirname(@__DIR__))
using ROOTprefs

#remove added projet from LOAD_PATH to ignore possible preference settings
filter!(!=(dirname(@__DIR__)), LOAD_PATH)

rootsys = ROOT_jll.root_path |> dirname |> dirname

@testset begin
    #Test default settings
    @test is_root_jll_used()
    @test is_root_version_checked()
    @test get_ROOTSYS() == ""

    #Test preference change
    use_root_jll!(false)
    @test !is_root_jll_used()
    check_root_version(false)
    @test !is_root_version_checked()
    set_ROOTSYS!(rootsys)
    @test get_ROOTSYS() == rootsys

    #Test extended features of set_ROOTSYS!()
    
    #  1. use of ROOTSYS environment variable
    set_ROOTSYS!("")
    withenv("ROOTSYS" => rootsys) do
        set_ROOTSYS!()
        @test get_ROOTSYS() == rootsys
    end

    #  2. Search of root-config in PATH
    set_ROOTSYS!("")
    @test get_ROOTSYS() == ""
    withenv("PATH" => join(vcat(ENV["PATH"], [joinpath(rootsys, "bin")]), ":")) do
        set_ROOTSYS!()
        @test get_ROOTSYS() == rootsys

        #  ROOTSYS must take precedence on root-config search
        withenv("ROOTSYS" => "from_ROOTSYS") do
            set_ROOTSYS!(nocheck=true)
            @test get_ROOTSYS() == "from_ROOTSYS"
        end

    end
    
    #   Test nocheck argument of set_ROOTSYS!()
    set_ROOTSYS!("foo", nocheck=true)
    @test get_ROOTSYS() == "foo"
    withenv("PATH" => "") do
        @test_throws ErrorException set_ROOTSYS!()
        @test get_ROOTSYS() == "foo"
    end
    withenv("ROOTSYS" => "from_ROOTSYS") do
        @test_throws ErrorException set_ROOTSYS!()
        set_ROOTSYS!(nocheck=true)
        @test get_ROOTSYS() == "from_ROOTSYS"
    end
end
