---
# Code Critique Competition 148

By Roger Orr, Manlio Morini, Paul Floyd, James Holland, William Grace

C Vu, 36(3):9-14, July 2024
---

Set and collated by Roger Orr. A book prize is awarded for the best entry.

Please note that participation in this competition is open to all members, whether novice or expert. Readers are also encouraged to comment on published entries, and to supply their own possible code samples for the competition (in any common programming language) to scc@accu.org.


## Last issue’s code

> I've written a very simple html escape processor but other people are reporting it sometimes doesn't work for them. What can I do? My test harness works fine.

Results of the test harness are in Listing 1, and the code is in Listing 2.

```Shell
$ html_escape
Testing <
Testing &lt;
And also >
And also &gt;
Then &
Then &amp;
A quote '
A quote &apos;
and a double quote "
and a double quote &quot;
That's all, folks!
That&apos;s all, folks!
```
Listing 1

```C++
#include <iostream>
#include <map>
#include <string>
#include <string_view>
std::map<char, std::string_view> escapes = {
    {'"', "quot"}, {'\'', "apos"},
    {'<', "lt"},   {'>', "gt"},
    {'&', "amp"},
};
void escape(std::istream &is,
            std::ostream &os) {
  std::string s;
  while (std::getline(is, s)) {
    for (auto ptr = s.begin(); *ptr != '\0';
         ++ptr) {
      std::string_view rep(escapes[*ptr]);
      if (!rep.empty()) {
        *ptr++ = '&';
        s.insert(ptr, ';');
        s.insert(ptr, rep.begin(), rep.end());
      }
    }
    os << s << '\n';
  }
}
// Test it
int main() { escape(std::cin, std::cout); }
```
Listing 2

## Critiques

### Manlio Morini

The main problem with the code is that it can trigger string memory reallocation, which invalidates iterators and can lead to writing to incorrect addresses.

Replacing a character (`*ptr++ = '&'`) is generally safe because it directly modifies existing characters without altering the overall length of the string.

However, calling `string::insert` can be problematic as it may require additional space to accommodate the inserted characters, potentially causing reallocation for a larger capacity.

#### Step-by-step debugging
(assuming a typical initial capacity of 15 characters and the input '<<<<<<<<<<<<<<<')

| Instruction           | Dump of `s.data()`                 | Notes        |
| ---                   | ---                                | ---          |
| `std::getline(is, s)` | `0x7fffffffe4e0: <<<<<<<<<<<<<<<.` |              |
| `*ptr++ = '&'`        | `0x7fffffffe4e0: &<<<<<<<<<<<<<<.` |              |
| `s.insert(ptr, ';')`  | `0x41d810000000: &;<<<<<<<<<<<<<<` | reallocation |
| `s.insert(ptr, rep...`|                                    | SIGABRT      |

The last instruction tries to write to the wrong address (`ptr` isn't valid anymore), possibly leading to an out-of-range exception being raised.

For a similar reason, even the "<<<<<" input could cause a segmentation fault, but it requires more steps.

This kind of bug can be mitigated by enabling an address sanitizer (`-fsanitize=address` switch with Clang/GCC) + fuzzing.

#### Additional considerations

##### `std::map` subscript operator

The subscript operator (`[]`) in `std::map` is convenient but potentially dangerous. It doesn't know whether you’re going to read from or write to the result, so it has to come up with some sort of compromise.

If the key isn't found in the map, `[]` creates a new entry consisting of the key and a default-constructed value, returning a reference to this new entry.

The result is that your map gets clogged with empty `string_view` objects, one for each key you probed.

##### Iterator Safety

`for (auto ptr = s.begin(); *ptr != '\0'; ++ptr)` is risky.

From C++11 onward, you can write:

```C++
for (char *ptr = s.data(); *ptr != '\0'; ++ptr) { }
```

since:

> In all cases, `[data(), data() + size()]` is a valid range, `data() + size()` points at an object with value `charT()` (a "null terminator"),

Alternatively, you can write:

```C++
for (auto ptr = s.begin(); ptr != s.end(); ++ptr) { }
```

but even considering all the peculiarities of `std::string`, dereferencing a past-the-end iterator (`*ptr != '\0'`) remains invalid.

GCC and Clang don't seem to complain but MSVC, in debug mode, is strict about this (see [this GitHub issue][1]).

##### Simplifications

Changing the map content, three insertions can be consolidated into a single one:

```C++
const std::map<char, std::string_view> escapes = {  // <-- const
  {'"', "&quot;"}, {'\'', "&apos;"},  // <-- single copy
  {'<', "&lt;",},  {'>', "&gt;"},
  {'&', "&amp;"}
};
```

##### Null byte injection

Be aware of security issues such as [null byte injection][2]:

```C++
int main() {
  using namespace std::string_literals;
  std::istringstream sin("\0<script>alert('Ohhh')</script>"s);
  escape(sin, std::cout);
}
```

In this case, text after the null character isn't escaped, which can be a security vulnerability.


#### Fixed source code

Instead of modifying the original string (`s`) in place, you can perform copying with on-the-fly replacement, which avoids having to move characters in the string. This will also result in better complexity and cache behaviour.

```C++
const std::map<char, std::string_view> escapes = {  // <-- const
  {'"', "&quot;"}, {'\'', "&apos;"},  // <-- single copy
  {'<', "&lt;",},  {'>', "&gt;"},
  {'&', "&amp;"}
};

void escape(std::istream &is, std::ostream &os) {
  std::string s;
  while (std::getline(is, s)) {
    std::string escaped;  // <-- new
    escaped.reserve(s.size());

    for (char c : s) {  // <-- simpler range-based for loop
      if (auto pos(escapes.find(c)); pos == escapes.end())
        escaped.push_back(c);
      else
        escaped.append(pos->second);
    }
    os << escaped << '\n';
  }
}
```

Of course you can completely avoid the `escaped` string and directly work on the output stream:

```C++
void escape(std::istream &is, std::ostream &os) {
  std::string s;
  while (std::getline(is, s)) {
    for (char c : s) {
      if (auto pos(escapes.find(c)); pos == escapes.end())
        os << c;
      else
        os << pos->second;
    }
    os << '\n';
  }
}
```


[1]: https://github.com/microsoft/STL/issues/4346
[2]: http://projects.webappsec.org/w/page/13246949/Null%20Byte%20Injection
