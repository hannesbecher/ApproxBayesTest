
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

myFun(params, constants, targetdata) = params[1], rand(1000) # return some extra ballast

println("Setting up ABC...")

# setup = ABCRejection(
#     myFun, # the simulation function
#     1, # num of params
#     th, # distance cutoff
#     nparticles=100, # number of accepted simulations required
#     Prior([Uniform(0.0,1.0)]),# priors must be in a list, even if only for one parameter
#     maxiterations=1e8
# )


setupSMC = ABCSMC(
    myFun, # the simulation function
    1, # num of params
    th, # distance cutoff
    nparticles=1000, # number of accepted simulations required
    Prior([Uniform(0.0,1.0)]),# priors must be in a list, even if only for one parameter
    kernel=ApproxBayes.gaussiankernel, # the kernel to use
    maxiterations=1e8
)

println("Running ABC...")

#results = runabc(setup, 1)
results = runabc(setupSMC, 1)
print(results)

writeoutput(results, file="out.abc")

savefig(plot(results), "out.png")

println("Done.")