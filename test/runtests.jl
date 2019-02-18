# It is suggested that test code for MLJ.jl include files be placed in
# a file of the same name under "test/" (and included below) and that
# this test code be wrapped in a module. Any new module name will do -
# eg, `module TestDatasets` for code testing `datasets.jl`.

# using Revise
using MLJBase
using Test

@testset "utilities" begin
  @test include("utilities.jl")
end

@testset "distributions" begin
  @test include("distributions.jl")
end

@testset "data" begin
  @test include("data.jl")
end

@testset "introspection" begin
  @test include("introspection.jl")
end

@testset "datasets" begin
  @test include("datasets.jl")
end


