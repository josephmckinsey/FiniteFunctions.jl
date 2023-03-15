using FiniteFunctions
using Test

@testset "FiniteFunctions.jl" begin
    pm = preimage(
        FiniteFunction(
            Dict([1 => 2, 2 => 3, 3 => 1, 4 => 4, 5 => 4])
        )
    )
    @test sort(pm(4)) == [4, 5]
    @test !(5 ∈ pm.src)
end
