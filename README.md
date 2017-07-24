# psychic-couscous

----
Update timestamp recursively using `touch`.

```bash
find . -exec touch -t 200101010101.01 {} +
```
----

Bessel's correction for R::scale compatibility.

```python
%load_ext rpy2.ipython
%%R
X <- matrix(sample(c(0,1,2), size=m*n, replace=TRUE), nrow=m, ncol=n)
z_ <- scale(M, center=TRUE, scale=TRUE)
z <- t(z)

import numpy as np
X = np.random.binomial(2, 0.5, size=(m, n))
z_ = (X.T - np.mean(X.T, axis=0)) / np.std(X.T, axis=0, ddof=1)
z = z_.T
"""
