rng = StableRNG(614)

# convert a Binary vector into vector of +1 or -1 values
# (for testing only):
pm1(y) = Int8(2) .* (Int8.(int(y))) .- Int8(3)

@testset "LossFunctions.jl - binary" begin
    y = categorical(["yes", "yes", "no", "yes"])
    yes, no = y[1], y[3]
    dyes = MLJBase.UnivariateFinite([yes, no], [0.6, 0.4])
    dno =  MLJBase.UnivariateFinite([yes, no], [0.3, 0.7])
    yhat = [dno, dno, dyes, dyes]
    X = nothing
    w = [1, 2, 3, 4]

    @test MLJBase.value(ZeroOneLoss(), yhat, X, y, nothing) ≈ [1, 1, 1, 0]
    @test MLJBase.value(ZeroOneLoss(), yhat, X, y, w) ≈ [1, 2, 3, 0] ./10 .* 4

    N = 10
    y = categorical(rand(rng, ["yes", "no"], N), ordered=true)
    levels!(y, ["no", "yes"])
    no, yes = MLJBase.classes(y[1])
    @test pm1([yes, no]) in [[+1, -1], [-1, +1]]
    ym = pm1(y) # observations for raw LossFunctions measure
    p_vec = rand(rng, N) # probabilities of yes
    yhat  = map(p_vec) do p
        MLJBase.UnivariateFinite([yes, no], [p, 1 - p])
    end
    yhatm = MLJBase._scale.(p_vec) # predictions for raw LossFunctions measure
    w = rand(rng, N)
    X = nothing

    for m in [ZeroOneLoss(), L1HingeLoss(), L2HingeLoss(), LogitMarginLoss(),
              ModifiedHuberLoss(), PerceptronLoss(), SmoothedL1HingeLoss(0.9),
              L2MarginLoss(), ExpLoss(), SigmoidLoss(), DWDMarginLoss(0.9)]
        @test MLJBase.value(m, yhat, X, y, nothing) ≈ LossFunctions.value(m, yhatm, ym)
        @test mean(MLJBase.value(m, yhat, X, y, w)) ≈
                LossFunctions.value(m, yhatm, ym, AggMode.WeightedMean(w))
    end
end

@testset "LossFunctions.jl - continuous" begin
    # losses for continuous targets:
    N    = 10
    y    = randn(rng, N)
    yhat = randn(rng, N)
    X    = nothing
    w    = rand(rng, N)

    for m in [LPDistLoss(0.5), L1DistLoss(), L2DistLoss(),
              HuberLoss(0.9), EpsilonInsLoss(0.9), L1EpsilonInsLoss(0.9),
              L2EpsilonInsLoss(0.9), LogitDistLoss(), QuantileLoss(0.7)]

        @test MLJBase.value(m, yhat, X, y, nothing) ≈ LossFunctions.value(m, yhat, y)
        @test mean(MLJBase.value(m, yhat, X, y, w)) ≈
                LossFunctions.value(m, yhat, y, AggMode.WeightedMean(w))
    end
end
