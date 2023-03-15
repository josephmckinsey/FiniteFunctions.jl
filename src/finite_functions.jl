"Finite Function interface"

using Markdown
import Tables

md"""
## Desired Operations

1. $f = g \circ h$.
2. $g(x) = f(x, y)$ (this could just be a combination of $i(x) = (x, y)$ which can be seen as combing a morphism $j(1) = y$ and then using the isomorphim $x \leftrightarrow (x, 1)$.
3. $g(y) = f^{-1}(y)$
4. $g(x) = f(x, -)$ (function valued)
5. $g(x) = \sum_y f(x, y) = \mathbb{E}(f(x, y) | ((x, y) \mapsto x))$.
6. $f(x, y) = g(x) \times g(y)$
7. $dup(x) = (x, x)$.
8. $g(a) = \mathbb{E}(f(b) | \phi)$ where $\phi(b) = a$. So what we really care about is this sort of labelled $\sigma$-algebra $\phi^{-1}$.
9. $h(i, k) = \mathbb{E}_j(\mathrm{prod} \circ (f \times g) \circ \mathrm{match}_{j=k}^{-1}(i, j, k, true))$ (matrix multiplication of $f(i, j)$ and $g(k, l)$) and $\mathrm{match}((i, j), (k, l)) = (i, j, l, j==k)$.
10. $2^X \Leftrightarrow S \hookrightarrow X$.
"""

# ╔═╡ ccefde19-f106-4cf7-89d3-a9b76711b21e
begin
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
    FiniteFunction(x -> f[x], 1:length(f), f)
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

end

# ╔═╡ b35fd3ad-d6da-48dd-8e3f-2381c543f3ce
begin
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
end

# ╔═╡ 93df2b1f-33b6-4433-9583-b28a86ae01c3
preimage(FiniteFunction(Dict([1 => 2, 2 => 3, 3 => 1, 4 => 4, 5 => 4])))

# ╔═╡ a7136667-2520-43dd-8322-aff941d229db
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
