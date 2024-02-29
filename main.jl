using Pkg
Pkg.add("BenchmarkTools")
using BenchmarkTools
using Distributed
using Random

addprocs(2)  # Add 2 worker processes

@everywhere function sample_M_distributed(N::Int64)
    rng = RemoteChannel(() -> MersenneTwister())
    M = @distributed (+) for _ in 1:N
        if (rand(rng)^2 + rand(rng)^2) < 1
            1
        else
            0
        end
    end
    return M
end

function estimate_pi_distributed(N::Int64)
    M = sample_M_distributed(N)
    est_pi = 4 * M / N
    return est_pi, abs(pi - est_pi)
end

N = 2^30

@btime estimate_pi_distributed(N)
