---
# Code Critique Competition 153

By Roger Orr, Manlio Morini, James Holland

C Vu, 37(2):13-18, May 2025
---

Set and collated by Roger Orr. A book prize is awarded for the best entry.

Please note that participation in this competition is open to all members, whether novice or expert. Readers are also encouraged to comment on published entries, and to supply their own possible code samples for the competition (in any common programming language) to scc@accu.org.


## Last issue's code

> I’m working on a simple card game, and I’ve started with the part that shuffles and deals the cards. It works for me with MSVC but when I use gcc it sometimes doesn’t display properly (and clang won’t even compile it).
>
> Example of wrong output from gcc showing unexpected “-1”:
>
> My hand is: -1, ace of spades, 3 of hearts, 3 of clubs, 7 of hearts, 7 of spades, and queen of hearts
>
> Their hand is: -1, 5 of clubs, 6 of clubs, 8 of clubs, 10 of hearts, 10 of clubs, and 10 of spades
>
> Can you suggest what the problem is, how best to fix it, and any other improvements you might suggest to the code as written?

card.h is in Listing 1, card.cpp is in Listing 2 and dealing.cpp is in Listing 3.

```C++
#pragma once
typedef enum {
  ace=1, jack=11, queen, king } rank;
typedef enum {
  hearts, diamonds, clubs, spades} suit;
struct card {
  rank rank_;
  suit suit_;
  bool operator<(card rhs) const {
    return rank_ < rhs.rank_ ||
           (rank_ == rhs.rank_ &&
            suit_ < rhs.suit_);
  }
};
const card joker{rank(-1), suit(-1)};
#include <set>
typedef std::set<card> hand;
#include <iostream>
std::ostream &operator<<(std::ostream &os,
                         rank r);
std::ostream &operator<<(std::ostream &os,
                         suit s);
std::ostream &operator<<(std::ostream &os,
                         card c);
std::ostream &operator<<(std::ostream &os,
                         hand h);
```
Listing 1

```C++
#include "card.h"
std::ostream &operator<<(std::ostream &os,
                         rank r) {
  switch (r) {
  case ace: os << "ace"; break;
  case jack: os << "jack"; break;
  case queen: os << "queen"; break;
  case king: os << "king"; break;
  case rank(-1): os << ""; break;
  default: os << +r;
  }
  return os;
}
std::ostream &operator<<(std::ostream &os,
                         suit s) {
  switch (s) {
  case hearts: os << " of hearts"; break;
  case diamonds: os << " of diamonds"; break;
  case clubs: os << " of clubs"; break;
  case spades: os << " of spades"; break;
  case suit(-1): os << "joker"; break;
  }
  return os;
}
std::ostream &operator<<(std::ostream &os,
                         card c) {
  return os << c.rank_ << c.suit_;
}
std::ostream &operator<<(std::ostream &os,
                         hand h) {
  size_t count = 0;
  for (card c : h) {
    if (count++)
      os << ", ";
    if (count == h.size())
      os << "and ";
    os << c;
  }
  return os;
}
```
Listing 2

```C++
#include "card.h"
// Two jokers
typedef card deck[54];
#include <algorithm>
#include <random>
void shuffle(deck &d) {
  std::random_device rd;
  std::mt19937 gen(rd());
  std::shuffle(d, d + 54, gen);
}
int main() {
  deck cards;
  for (int r = 1; r <= 13; r++) {
    for (int s = 0; s < 4; s++) {
      cards[r * 4 + s - 4].rank_ = rank(r);
      cards[r * 4 + s - 4].suit_ = suit(s);
    }
  }
  cards[52] = joker;
  cards[53] = joker;
  shuffle(cards);
  // deal
  hand hands[2];
  for (int i = 0; i < 14; ++i) {
    hands[i % 2].insert(cards[i]);
  }
  std::cout << "My hand is: " << hands[0]
            << '\n';
  std::cout << "Their hand is: " << hands[1]
            << '\n';
}
```
Listing 3

## Critiques

### Manlio Morini

The root of the problem lies in the way your enums are defined. Consider these definitions:

```C++
enum rank { ace = 1, jack = 11, queen, king };
enum suit { hearts, diamonds, clubs, spades };
```

Because these are unscoped enumerations without a fixed underlying type, the type chosen by the compiler is implementation-defined. GCC and CLANG choose an `unsigned` type that only covers the range of values explicitly specified (e.g. from 0 upward), while MSVC chooses int. When you write expressions like `rank(-1)` or `suit(-1)`, you are explicitly converting values that fall outside the valid range of the enumeration.

The fact is that the C++ standard states:

> A value of integral or enumeration type can be explicitly converted to a complete enumeration type. [CUT] If the enumeration type does not have a fixed underlying type, the value is unchanged if the original value is within the range of the enumeration values ([dcl.enum]), and otherwise, the behavior is undefined.
>
> (https://eel.is/c++draft/expr.static.cast#9 [expr.static.cast] If the value is not a bit-field, the result refers to the object or the specified base class subobject thereof; otherwise, the lvalue-to-rvalue conversion is applied to the bit-field and the resulting prvalue is used as the operand of the static_cast for the remainder of this subclause.)

thus **you are triggering undefined behaviour**, meaning anything can happen (different compilers will handle it inconsistently, causing hard-to-debug errors).

To ensure the underlying type is `int` (which can represent negative values), you can modify the enums by adding an extra enumerator for the “null” case and avoid the undefined behaviour:

```C++
enum rank { null_rank = -1, ace = 1, jack = 11, queen, king };
enum suit { null_suit = -1, hearts, diamonds, clubs, spades };
```

Note: GCC and CLANG provide an *UndefinedBehaviorSanitizer* (UBSan), which can be enabled with `-fsanitize=undefined` – a very useful tool. Additionally, always pay close attention to compiler warnings and strive to produce code that compiles without warnings.

Another important issue is the use of `std::set` for the player's hand. Since `std::set` only allows unique elements, having two jokers in your deck means one will be omitted if both are dealt to the same hand. You have a couple of simple options to address this:

- use `std::multiset`: this container permits duplicate elements while still keeping the cards sorted;
- use `std::vector`: if you do not require automatic sorting, a vector might be simpler to work with.

The `shuffle` function presents a moderate issue:

```C++
void shuffle(deck &d)
{
  std::random_device rd;
  std::mt19937 gen(rd());
  std::shuffle(d, d + 54, gen);
}

The purpose of `std::random_device` is to provide a random seed for the generator.

If you seed a new generator for every shuffle, you reduce the effectiveness of the generator’s randomness by biasing it toward the randomness provided by the random device.

Also:

- `std::random_device` can be expensive to call because it requires entropy to deliver a *truly random* number;
- `std::mt19937` is not cheap to create and is expensive to seed.

These factors suggest a different implementation:

```C++
void shuffle(deck &d)
{
  static std::mt19937 gen(std::random_device{}());
  std::shuffle(d, d + 54, gen);
}
```

A minor issue is that output operators assume a specific sequence (namely that `operator<<(std::ostream&, suit)` is always called after `operator<<(std::ostream&, rank)`) and so they aren’t completely general.

A possible change follows:

```C++
std::ostream &operator<<(std::ostream &os, rank r)
{
  switch (r)
  {
  case null_rank:  break;
  case ace:        os << "ace"; break;
  case jack:       os << "jack"; break;
  case queen:      os << "queen"; break;
  case king:       os << "king"; break;
  default:         os << +r;  break;
  }
  return os;
}

std::ostream &operator<<(std::ostream &os, suit s)
{
  switch (s)
  {
  case hearts:    os << "hearts"; break;
  case diamonds:  os << "diamonds"; break;
  case clubs:     os << "clubs"; break;
  case spades:    os << "spades"; break;
  default:        break;
  }
  return os;
}

std::ostream &operator<<(std::ostream &os, card c)
{
  if (joker < c)
    os << c.rank_ << " of " << c.suit_;
  else
    os << "joker";
  return os;
}
```

Other aspects should be considered.

First, several “magic numbers” could be replaced with named constants or more expressive constructs.

1. Since C++ doesn’t offer a built-in way to determine the minimum and maximum values of an `enum`, it’s good practice to define explicit boundary values. For example, for `suit` you might add:

   ```C++
   enum suit { null_suit = -1, hearts, diamonds, clubs, spades, first_suit = hearts, last_suit = spades };
   ```

   This makes loops over the `enum` values more readable.

2. Instead of using a fixed-size array (defined by `typedef card deck[54]`), consider using a `std::vector<card>`. This not only avoids hardcoding the number of cards (you can call `deck.size()`), but also simplifies operations such as shuffling:

   ```C++
   std::shuffle(deck.begin(), deck.end(), gen);
   ```

   and dealing cards becomes clearer:

   ```C++
   deck cards = {joker, joker};
   for (int r = ace; r <= king; ++r)
     for (int s = first_suit; s <= last_suit; ++s)
        deck.push_back({rank(r), suit(s)});
   ```

Lastly consider the coding style:

- place all your include directives at the beginning of the source file to ensure that dependencies are clear at a glance;
- in C, you might have used a `typedef` with enums (e.g. `typedef enum MyEnum { ... } MyEnum;`) so that you don’t have to write `enum MyEnum` every time. However, in C++ the `enum` itself is a type, so the `typedef` isn’t necessary.

Both of these recommendations follow the **principle of least astonishment**, meaning the design should align with the user’s expectations and mental models.

```C++
--- Dealing.cpp ---

#include "card.h"
#include <algorithm>
#include <random>
#include <vector>

typedef std::vector<card> deck;

void shuffle(deck &d)
{
  static std::mt19937 gen(std::random_device{}());
  std::shuffle(d.begin(), d.end(), gen);
}

int main()
{
  deck cards = {joker, joker};
  for (int r = ace; r <= king; ++r)
    for (int s = first_suit; s <= last_suit; ++s)
      cards.push_back({rank(r), suit(s)});
  shuffle(cards);
  // deal
  hand hands[2];
  for (int i = 0; i < 14; ++i) {
    hands[i % 2].insert(cards[i]);
  }
  std::cout << "My hand is: " << hands[0] << '\n';
  std::cout << "Their hand is: " << hands[1] << '\n';
}
```

```C++
--- Card.cpp ---

#include "card.h"
std::ostream &operator<<(std::ostream &os, rank r)
{
  switch (r)
  {
  case null_rank:  break;
  case ace:        os << "ace"; break;
  case jack:       os << "jack"; break;
  case queen:      os << "queen"; break;
  case king:       os << "king"; break;
  default:         os << +r;  break;
  }
  return os;
}

std::ostream &operator<<(std::ostream &os, suit s)
{
  switch (s)
  {
    case hearts:    os << "hearts"; break;
    case diamonds:  os << "diamonds"; break;
    case clubs:     os << "clubs"; break;
    case spades:    os << "spades"; break;
    default:        break;
  }
  return os;
}

std::ostream &operator<<(std::ostream &os, card c)
{
  if (joker < c)
    os << c.rank_ << " of " << c.suit_;
  else
    os << "joker";
  return os;
}

std::ostream &operator<<(std::ostream &os, hand h)
{
  size_t count = 0;
  for (card c : h)
  {
    if (count++)
      os << ", ";
    if (count == h.size())
      os << "and ";
    os << c;
  }
  return os;
}
```

```C++
--- Card.h ---

#pragma once
#include <iostream>
#include <set>
enum rank {null_rank = -1, ace = 1, jack = 11, queen, king};
enum suit {null_suit = -1, hearts, diamonds, clubs, spades, first_suit = hearts, last_suit = spades};

struct card
{
  rank rank_;
  suit suit_;

  bool operator<(card rhs) const
  {
    return rank_ < rhs.rank_ || (rank_ == rhs.rank_ && suit_ < rhs.suit_);
  }
};

const card joker{null_rank, null_suit};

typedef std::multiset<card> hand;

std::ostream &operator<<(std::ostream &os, rank r);
  std::ostream &operator<<(std::ostream &os, suit s);
  std::ostream &operator<<(std::ostream &os, card c);
  std::ostream &operator<<(std::ostream &os, hand h);
```

[CUT]

## Commentary

This time I’ve nothing to add beyond what is covered by the entries for this critique.

## The winner of CCC 152

Both entries discussed the troubling use of -1 to “fake” an enumeration value. The constant ‘-1’ is not a valid value for either enumeration and so the compiler can assume any `case` statement with this value can be omitted in the switch statement. (The C++ rules mean the ‘rank’ enumeration technically only allows values 0 to 15 inclusive and ‘`suit`’ allows no values other than the four values named, covering 0 to 3 inclusive.)

As James points out, in C++ there is no point using `typedef` for the enumerations. (This is different in C, where omission would force the use of enum where the type is used.)

Manlio noted that the data structure chosen cannot process a hand with two jokers and proposed two alternative structures that can. This is the sort of design problem that can cause serious redesign issues for large projects!

James proposed adding named enumerators for ‘joker’ and this leads him to using scoped enumerations to avoid the name clash caused by the ‘leakage’ of unscoped enumerators outside their defining enumeration; Manlio chose distinct names but I would probably prefer using scoped enumerations anyway, especially since P1099 allows `using enum` if you do want to pull the enunerator names into a scope.

Manlio added some useful commentary on the downsides of the naive random number generation. Depending on your precise use case you may be more concerned about either (or both) of the issues he raises. Simple testing on my laptop shows about 6-8 microseconds of overhead with the naive implementation, which could be significant in some use cases.

Manlio suggested using Ubsan which is a very good suggestion; although note of course that sanitizers only operate when the behaviour actually occurs at runtime so executing the program without fault does not prove the absence of undefined behaviour for other executions.

Both entries also discussed better ways to handle the various ‘magic numbers’ in the sample code. This can be quite a problem in code bases where the numerical value was ‘obvious’ to the person writing the code initially but becomes unclear on later re-reading (even by the same programmer.)

I think the writers of both entries did a very good job, but in my opinion Manlio’s entry wins by a short head; so I offer him my congratulations!
