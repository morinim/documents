# Calculating the Relative Difference between numbers

## Comparing Two Numbers

When comparing two numbers, subtracting the smaller from the larger yields the difference between them. Examples:

```
  5 -                 101 -

  3 =                  99 =
---                   ---
  2                     2
```

In both cases, the difference is the same, `2`. For some purposes, that difference tells us all we need to know, but there is at least one sense in which the numbers `99` and `101` are closer to each other than are the numbers `3` and `5`.

This notion is expressed in the phrase: *“differing by one part in 100”* or *“differing by one part in 1000”*. Clearly, numbers that differ by `1` part in `1000` are closer to each other than numbers that differ by `1` part in `100`. Specifically, in the example above, `3` and `5` differ by `2` parts in `5`, whereas `99` and `101` differ by `2` parts in `101`.

The mathematically precise way to express this notion is to calculate the relative difference. The method for calculating relative difference is as follows:

1. subtract the smaller number from the larger number;
2. calculate the average of the two numbers;
3. divide the answer from (1) by the answer from (2).

Applying this to the example above:

- the relative difference between `5` and `3` is `(5-3)/4 = 2/4 = .5`;
- the relative difference between `101` and `99` is `(101-99)/100 = 2/100 = .02`.

As you can tell by the results, numbers with smaller relative differences are closer to each other.

More examples:

- the relative difference between `49` and `51` is `(51-49)/50 = 2/50 = .04`;
- the relative difference between `999.5` and `1000.5` is `(1000.5-999.5)/1000 = .001`;
- the relative difference between `999.9` and `1000.1` is `(1000.1-999.9)/1000 = .0002`.

## The Relative Difference When One Number is Zero

Now consider these examples, where one of the two numbers being compared is zero:

- the relative difference between `10` and `0` is `(10-0)/5 = 2`;
- the relative difference between `1000` and `0` is `(1000-0)/500 = 2`
- the relative difference between `.000001` and `0` is `(.000001-0)/.0000005 = 2`.

Hold on. In all cases, the relative difference between `0` and another number is `2`. Even when the other number is very small, the difference is still `2`. Does this make sense?

Ordinarily, we think of smaller numbers as being closer to `0`. This means that the 3ʳᵈ example should have yielded a smaller relative difference (but it didn't).

## How Calculations Are Actually Performed

Before we offer a solution we need to review how computers (and humans) perform calculations. The key issue is the number of digits of precision used in the calculations. We show two calculations that are from the same process but differ in the number of significant digits.

**Six Digits of Precision**
```
9876.54 -
9876.54 =
-------
   0.00
```

**Seven Digits of Precision**
```
9876.544 -
9876.541 =
--------
   0.003
```
In the first example we get a zero result. In the second example we get a non-zero result. Which is correct? The more correct answer is the non-zero one.

Actually, obtaining a zero result in a calculation is more likely than not to be the result of using too few digits of precision in the calculation. Obtaining an exactly zero amount is really very, very unlikely.

So, it turns out that most of the time, when calculating a relative difference where one of the numbers is zero, you are working with an imprecise number, one that if calculated with more digits would have yielded a different result.

## Another Case of Too Few Digits of Precision

There is another situation where having too few digits of significance in calculations makes a significant difference in the relative difference calculation. Consider these two calculations from the same program, one using six digits of precision, the other using seven digits of precision.

**Six Digits of Precision**
```
.987654 -             .987654 -
.987653 =             .987653 =
-------               -------
.000001               .000001
```
The relative difference is `(.000001-.000001)/.000001 = 0`.

**Seven Digits of Precision**
```
.9876549 -            .9876549 -
.9876535 =            .9876531 =
--------              --------
.0000014              .0000018
```

The relative difference is `(.0000018-.0000014)/.0000016=.25`.

Wait. In the first example there is no relative difference as the numbers are identical. In the second there is a huge relative difference. What is going on here?

Just as was the case with zero, calculating results with fewer digits of precision results in misleading or erroneous conclusions about relative difference.

## Solution

The reality is that due to the nature of calculation, there is no real, substantial or effective difference between very small numbers. Had more digits of precision been used, the actual very small numbers we would be working with would have had quite different values.

The solution proposed here involves defining a `floor` value. All numbers below the `floor` value are very small numbers, whose difference in value are inconsequential. Whenever we encounter a number that is smaller than the `floor`, we replace it with the value of the `floor`.

In the example just above, we might define the floor as `.00001`. Both `.0000014` and `.0000018` are smaller than the `.00001`, so we replace both of them with the `.0001`. In the relative difference calculation two identical numbers are being compared, so the answer comes out `0`.

Zero is actually a very small number as well. Whenever we encounter a zero in the relative difference calculation we replace it with the value of the floor. This is consistent with the earlier idea that had the calculations used more digits of precision, the result would not be zero but instead a very small number.

Ideally, all calculations would be performed with an unlimited number of significant digits of precision. But, in the real world, all calculations, by human or computer, are done with a finite number of significant digits. The floor concept allows us to make meaningful judgments on the relative closeness of two numbers even when we don't have an adequate number of digits of precision in our calculations.

## References
- [Relative change and difference](https://en.wikipedia.org/wiki/Relative_change_and_difference) on Wikipedia
