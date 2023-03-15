"""Finite Function interface"""
module FiniteFunctions

import Tables

struct FiniteFunction{S, T}
    f::Function
    src::S
    tgt::T
end

function FiniteFunction(f::Dict{S, T}) where {S, T}
    FiniteFunction(x -> f[x], collect(keys(f)), unique(collect(values(f))))
end

function FiniteFunction(f::Dict{S, T}, tgt) where {S, T}
    FiniteFunction(x -> f[x], collect(keys(f)), tgt)
end

function FiniteFunction(f::Vector{Pair{U, V}}) where {U, V}
    src = first.(f)
    tgt = last.(f)
    d = Dict(f)
    FiniteFunction(x -> d[x], src, tgt)
end

function FiniteFunction(f::Vector{Pair})
    src = first.(f)
    tgt = last.(f)
    d = Dict(f)
    FiniteFunction(x -> d[x], src, tgt)
end

function FiniteFunction(f::Vector{T}, tgt) where {T}
    FiniteFunction(x -> f[x], 1:length(f), tgt)
end

function FiniteFunction(f::Function, src)
    FiniteFunction(f, src, unique(f.(src)))
end

function (f::FiniteFunction)(x)
    f.f(x)
end

function Base.:∘(f::FiniteFunction, g::FiniteFunction)
    FiniteFunction(f.f ∘ g.f, g.src, f.tgt)
end

function Base.:∘(f::Function, g::FiniteFunction)
    FiniteFunction(f ∘ g.f, g.src, Any)
end

function reset_target(f::FiniteFunction, tgt)
    FiniteFunction(f.f, f.src, tgt)
end

function reset_target(f::FiniteFunction)
    FiniteFunction(f.f, f.src, unique(f.(f.src)))
end

function preimage(f::FiniteFunction)
    d = Dict([y => [] for y in f.tgt])
    for x in f.src
        v = f.f(x)
        if !haskey(d, v)
            error("Unknown target $v evaluated in function")
        end
        push!(d[v], x)
    end
    return FiniteFunction(x -> d[x], f.tgt, Any)
end

function inverse(f::FiniteFunction)
    d = Dict([f(s) => s for s in f.src])
    return FiniteFunction(x -> d[x], f.tgt, f.src)
end

function Base.reduce(op, f::FiniteFunction; kwargs...)
    reduce(op, f.(f.src); kwargs...)
end

"""
    reduce_cond(op, f, phi)

This does a reduction operation, except that we get a mapping from
the target of phi to the target of f
"""
function reduce_cond(op, f::FiniteFunction, phi::FiniteFunction; kwargs...)
    pre_phi = preimage(phi)
    (atom -> reduce(op, map(f, atom); kwargs...)) ∘ pre_phi
end

function rarify(f::FiniteFunction)
    d = Dict([x => f(x) for x in f.src])
    FiniteFunction(x -> d[x], f.src, f.tgt)
end

function image(f::FiniteFunction)
    return f.(f.src)
end

function reset_src(f::FiniteFunction, src)
    # Could also compose with (identity, src, f.src)
    FiniteFunction(f.f, src, f.tgt)
end

function table_to_ff(table, src_f, tgt_f)
    d = Dict([src_f(r) => tgt_f(r) for r in Tables.rows(table)])
    table_len = length(Tables.rows(table))
    @assert length(keys(d)) == table_len begin
        "Length of dictionary $(length(keys(d))) does not match length of dataframe $table_len"
    end
    FiniteFunction(d)
end

function invertible(ff::FiniteFunction)
    im = image(ff)
    length(ff.src) == length(ff.tgt) && allunique(im)
end

function injective(ff::FiniteFunction)
    allunique(image(ff))
end

export FiniteFunction
export preimage, inverse, reduce_cond, rarify, image, invertible, injective
export reset_src, table_to_ff

end
