# RECURSIVE CTE IN FIREBIRD

This article provides a clear and structured example to help understand how recursive Common Table Expressions (CTEs) work in Firebird. The example chosen is simple yet non-trivial, demonstrating the practical usage of recursive CTEs.

## Introduction

A recursive common table expression is a CTE that references itself. By doing so, the CTE executes repeatedly, returning subsets of data until it produces the complete result set.

Recursive CTEs are particularly useful for querying hierarchical data.

The general syntax is:

```sql
with CTE_NAME(COLUMN_LIST) as (
  -- anchor member (base case)
  initial_query

  union all

  -- recursive member that references CTE_NAME
  recursive_query
)
-- references the recursive CTE
select *
from   CTE_QUERY
```

A recursive CTE consists of three parts:

- **anchor member**. An initial query that returns the base result set of the CTE;
- **recursive member**. A query that references the CTE itself and is combined with the anchor member using the `union all` operator;
- **termination condition**. A condition in the recursive member that stops the recursion when met.

## Execution order

The execution order of a recursive CTE proceeds as follows:

- execute the **anchor member** to form the base result set ($R_0$). Use this result for the next iteration;
- execute the **recursive member** with the input result set from the previous iteration ($R_{i-1}$) and return a sub-result set. Repeat until the termination condition is met;
- combine all result sets using `union all` operator to produce the final result set.

The following flowchart illustrates the execution of a recursive CTE:

```
           ( START )
               ↓
       [ Execute anchor ]    ............ return R0
       [     member     ]
               |
               ↓
      [ Execute recursive ]  ............ return Ri
  +--→[      member       ]
  |            |
  |            ↓
  |            ^
  +-No---< Terminate? >
               ˇ
               | Yes
               ↓
         [ union all ]
         [ R0, R1... ]
               |
               ↓
           ( STOP  )
```

## Example

Consider the following tables:

```sql
create table WORKS_WITH_BASE_COSTS
(
  CODE      integer not null,
  BASE_COST decfloat default 0 not null,
  constraint PK_WORKS_WITH_BASE_COSTS primary key (CODE)
);

create table WORKS_STRUCT
(
  PARENT_CODE integer not null,
  CHILD_CODE  integer not null,
  QUANTITY    decfloat not null,
  constraint PK_WORKS_STRUCT primary key (PARENT_CODE, CHILD_CODE)
);
```

### Sample data

**WORKS_WITH_BASE_COSTS**

| CODE | BASE_COST |
| ---  | ---       |
| 1    | 10.0      |
| 2    | 30.0      |
| 3    |  0.0      |
| 4    |  5.0      |
| 5    |  0.0      |
| 6    | 20.0      |
| 7    |  0.0      |

**WORKS_STRUCT**

| PARENT_CODE | CHILD_CODE | QUANTITY |
| ---         | ---        | ---      |
| 3           | 1          |  4.0     |
| 3           | 2          |  2.0     |
| 5           | 4          | 10.0     |
| 5           | 6          |  5.0     |
| 7           | 3          |  4.0     |
| 7           | 5          |  1.0     |

These tables encode the following tree structure:

```
    (7)
     |
     +----(3)
     |     |
     |     +----(1) € 10.0
     |     |
     |     +----(2) € 30.0
     |
     +----(5)
           |
           +----(4) €  5.0
           |
           +----(6) € 20.0
```

We want to create a `view` that calculates the total cost of every work:

```
    (7) € 550.0 (4.0*100.0 + 1.0*150.0)
     |
     +----(3) € 100.0 (4.0*10.0 + 2.0*30.0)
     |     |
     |     +----(1) € 10.0
     |     |
     |     +----(2) € 30.0
     |
     +----(5) € 150.0 (10.0*5.0 + 5.0*20.0)
           |
           +----(4) €  5.0
           |
           +----(6) € 20.0
```

### Recursive CTE query

The following query calculates the total cost:

```sql
with recursive COMPUTED_COSTS(CODE, COST) as (
  -- anchor member
  select CODE, BASE_COST
  from   WORKS_WITH_BASE_COSTS

  union all

  -- recursive member
  select WS.PARENT_CODE, CC.COST * WS.QUANTITY
  from   COMPUTED_COSTS CC
         join WORKS_STRUCT WS on CC.CODE = WS.CHILD_CODE
)
select   CODE, sum(COST)
from     COMPUTED_COSTS
group by CODE
```

### Step by step explanation

The **anchor member**

```sql
select CODE, BASE_COST as COST
from   WORKS_WITH_BASE_COSTS
```

selects the base cost for each work, resulting in the initial set ($R_0$):

| CODE | COST |
| ---  | ---  |
| 1    | 10.0 |
| 2    | 30.0 |
| 3    |  0.0 |
| 4    |  5.0 |
| 5    |  0.0 |
| 6    | 20.0 |
| 7    |  0.0 |

The **recursive member**:

```sql
select WS.PARENT_CODE, CC.COST * WS.QUANTITY
from   COMPUTED_COSTS CC
       join WORKS_STRUCT WS on CC.CODE = WS.CHILD_CODE
```

calculates the cost for parent nodes by combining the costs of their child nodes, adjusted by the quantity, producing $R_1$:

| CODE | COST  |
| ---  | ---   |
| 3    |  40.0 |
| 3    |  60.0 |
| 7    |   0.0 |
| 5    |  50.0 |
| 5    | 100.0 |
| 7    |   0.0 |

The next iteration produces $R_2$:

| CODE | COST  |
| ---  | ---   |
| 7    | 160.0 |
| 7    |  60.0 |
| 7    |  50.0 |
| 7    | 100.0 |

At this point, the remaining code (`7`) is not the child of any node. The first `join` in the recursive member produces an empty set, stopping the recursion.

The final result is $R_0 \cup R_1 \cup R_2$:

```
R_0                 R_1                  R_2
| CODE | COST |     | CODE | COST  |     | CODE | COST  |
| ---  | ---  |     | ---  | ---   |     | ---  | ---   |
| 1    | 10.0 |     | 3    |  40.0 |     | 7    | 160.0 |
| 2    | 30.0 |     | 3    |  60.0 |     | 7    |  60.0 |
| 3    |  0.0 |     | 7    |   0.0 |     | 7    |  50.0 |
| 4    |  5.0 |     | 5    |  50.0 |     | 7    | 100.0 |
| 5    |  0.0 |     | 5    | 100.0 |
| 6    | 20.0 |     | 7    |   0.0 |
| 7    |  0.0 |
```

### Final Aggregation

The query

```sql
select   CODE, sum(COST)
from     COMPUTED_COSTS
group by CODE
```

groups and sums costs by code to produce the desired result:

| CODE | COST  |
| ---  | ---   |
| 1    |  10.0 |
| 2    |  30.0 |
| 3    | 100.0 |
| 4    |   5.0 |
| 5    | 150.0 |
| 6    |  20.0 |
| 7    | 550.0 |

For simplicity in calculations, this example assumes that only leaves have `BASE_COST<>0`. However, this is not a requirement.

## Limitations

- Recursive queries can become expensive for deep or wide hierarchies.
- The example assumes a properly structured hierarchy without cycles. To enforce this, you could add constraints to ensure the data is acyclic and use techniques like cycle detection in the recursive query itself.

## Conclusion

Recursive CTEs are a powerful tool for handling hierarchical data in Firebird. This example demonstrates how they can be used to compute costs for a tree-like structure efficiently and concisely.

## References

- [Recursive CTE in Firebird for calculating aggregate costs in hierarchical data](https://stackoverflow.com/q/79348486/3235496)
