---
TL;DR
No matter how simple your code may be, there's no substitute for testing it to make sure it's actually doing what you think it is.
---

When asked to perform hold-out validation, Vita takes the input `dataframe`, containing all the available data, and moves a given percentage of random examples to a validation `dataframe`.

Initially the two steps of the partitioning were:

1. a complete shuffle of the input `dataframe` via `std::shuffle`;
2. a shift of the last portion of the shuffled input `dataframe` to a new validation `dataframe`.

Step 1 was sub-optimal since the validation dataset is usually small compared to the training set. We can easily perform a partial shuffle with the [Fisher-Yates algorithm](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle).

## Fisher-Yates (modern) algorithm

The general idea is to start from the last element and swap it with a randomly selected element from the whole array including the last one (so in the $0$ to $n−1$ range). Then consider the slice from $0$ to $n−2$ (size reduced by 1), and repeat the process till hitting the first element:

```Python
from random import randint

def shuffle(arr):
    for i in range(len(arr)-1, 0, -1):
        j = randint(0, i)
        arr[i], arr[j] = arr[j], arr[i]

    return arr
```

and, for a *partial* shuffle:

```Python
from random import randint

def shuffle(arr, skip):
    for i in range(len(arr)-1, skip-1, -1):
        j = randint(0, i)
        arr[i], arr[j] = arr[j], arr[i]

    return arr
```

After such a partial shuffle, the slice `arr[k],arr[k+1],...,arr[n−1]` contains a randomly shuffled uniform sample of $n−k$ values drawn, without replacement, from the original array arr.

The entire shuffle can be performed in-place, without any extra space. Time complexity is $O(k)$ (the algorithm needs to shuffle each item only once).

## Hint of correctness
The probability that a given element of the original array (say the $i$-th element) goes to last position of the shuffled array is $1/n$, because we randomly pick an element in first iteration.

The probability that $i$-th element goes to second last position can be proved to be $1/n$ considering the two cases:

1. $i=n−1$ (**index of last element**).

    The probability of last element going to second last position is:

    $$
    \mathbb{A} = "last\ element\ doesn't\ stay\ at\ its\ original\ position"\\
    \mathbb{B} = "index\ picked\ in\ previous\ step\ is\ picked\ again"\\
    \begin{eqnarray}P(\mathbb{A}) \cdot P(\mathbb{B}) = \frac{n-1}{n} \cdot \frac{1}{n-1} = \frac{1}{n}\end{eqnarray}
    $$

2. $0 < i < n-1$ (**index of non-last**).

    The probability of $i$-th element going to second position is:

    $$
    \mathbb{A} = "i-th\ element\ is\ not\ picked\ in\ previous\ iteration"\\
    \mathbb{B} = "i-th\ element\ is\ picked\ in\ this\ iteration"\\
    \begin{eqnarray}P(\mathbb{A}) \cdot P(\mathbb{B}) = \frac{n-1}{n} \cdot \frac{1}{n-1} = \frac{1}{n}\end{eqnarray}
    $$
