push!(LOAD_PATH,"../src/")
using Documenter, ROOTprefs

makedocs(
    sitename = "ROOTprefs.jl",
    modules = [ROOTprefs],
    checkdocs = :exports,
    repo = "https://github.com/JuliaHEP/ROOTprefs.jl/blob/{commit}{path}#L{line}",
    format = Documenter.HTML(
        prettyurls = false,
        repolink = "https://github.com/JuliaHEP/ROOTprefs.jl"
    )
)

deploydocs(
    repo = "github.com/JuliaHEP/ROOTprefs.jl",
    push_preview = true
)

