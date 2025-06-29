
# run ABC

# USAGE: julia +1.10 runAbc.jl <threshold>

using Pkg
Pkg.activate(".")
Pkg.instantiate()

using ApproxBayes
using Distributions
using Plots

th = parse(Float64, ARGS[1])
th <= 1.0 || error("Threshold must be <= 1.0")
th >= 0.0 || error("Threshold must be >= 0.0")

# "simulation" functions with differen variances
myFunS1(params, constants, targetdata) = abs(params[1] + randn()), rand(100) # return some extra ballast
myFunS5(params, constants, targetdata) = abs(params[1] + randn()*5), rand(100) # return some extra ballast
myFunS01(params, constants, targetdata)= abs(params[1] + randn()*params[2]), rand(100)
println("Setting up ABC...")


setupSMC = ABCRejectionModel(
    [myFunS1, myFunS5, myFunS01], # the simulation function
    [1, 1, 2], # num of params
    th, # distance cutoff
    nparticles=10000, # number of accepted simulations required
     [Prior([Uniform(-1/2,1/2)]),
     Prior([Uniform(-1/2,1/2)]),
     Prior([Uniform(-1/2,1/2),
     Uniform(0.0,1.0)])
    ],# priors must be in a list, even if only for one parameter
    #kernel=ApproxBayes.gaussiankernel, # the kernel to use
    maxiterations=1e8
)

println("Running ABC...")

#results = runabc(setup, 1)
results = runabc(setupSMC, 1)
print(results)

println("Model freq: $(results.modelfreq)")
#println("Model prob: $(results.modelprob)") # does not exist in rejectionmodels

writeoutput(results, file="outRejModels.abc")

savefig(plot(results), "outRejModels0.png")
for i in 1:3
    savefig(plot(results, i), "outRejModels$(i).png")
end
println("Done.")