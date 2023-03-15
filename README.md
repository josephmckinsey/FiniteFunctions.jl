# FiniteFunctions.jl

Tries to reframe relational data in terms of functions over finite domain.

## Desired Operations

1. $f = g \circ h$.

2. $g(x) = f(x, y)$ (this could just be a combination of $i(x) = (x, y)$ which can be seen as combing a morphism $j(1) = y$ and then using the isomorphim $x \leftrightarrow (x, 1)$.

3. $g(y) = f^{-1}(y)$

4. $g(x) = f(x, -)$ (function valued)

5. $g(x) = \sum_y f(x, y) = \mathbb{E}(f(x, y) | ((x, y) \mapsto x))$.

6. $f(x, y) = g(x) \times g(y)$

7. $dup(x) = (x, x)$.

8. $g(a) = \mathbb{E}(f(b) | \phi)$ where $\phi(b) = a$. So what we really care about is this sort of labelled $\sigma$-algebra $\phi^{-1}$.

9. $h(i, k) = \mathbb{E}_j(\mathrm{prod} \circ (f \times g) \circ \mathrm{match}_{j=k}^{-1}(i, j, k, true))$
(matrix multiplication of $f(i, j)$ and $g(k, l)$) and $\mathrm{match}((i, j), (k, l)) = (i, j, l, j==k)$

10. $2^X \Leftrightarrow S \hookrightarrow X$.
