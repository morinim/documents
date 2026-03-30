# How to support `std::format` with custom classes

[`std::format`](https://en.cppreference.com/w/cpp/utility/format/format.html) only knows how to format types for which a [`std::formatter`](https://en.cppreference.com/w/cpp/utility/format/formatter.html) exists. For built-in types this is already provided, but for your own classes you need to define one.

I.e. this will not compile:

```C++
MyType x;
auto s = std::format("Value: {}", x);
```


## Basic idea

To make a custom class formattable, specialise `std::formatter` for that type and implement two member functions:

- `parse()` to read any format specifiers;
- `format()` to write the formatted output.

### Minimal example

```C++
#include <format>
#include <string>

class point
{
public:
  point(int x, int y) : x_(x), y_(y) {}

  [[nodiscard]] int x() const noexcept { return x_; }
  [[nodiscard]] int y() const noexcept { return y_; }

private:
  int x_;
  int y_;
};

template<> struct std::formatter<point>
{
  [[nodiscard]] constexpr auto parse(std::format_parse_context &ctx)
  {
    auto it(ctx.begin());
    if (it != ctx.end() && *it != '}')
      throw std::format_error("invalid format");
    return it;
  }

  [[nodiscard]] auto format(const point &p, std::format_context &ctx) const
  {
    return std::format_to(ctx.out(), "({}, {})", p.x(), p.y());
  }
};
```

Now you can write:

```C++
point p(3, 7);
auto s = std::format("Point: {}", p);
```

and obtain:

```
Point: (3, 7)
```

**`parse()` must be `constexpr` for the compiler to validate format strings at compile-time**.


## Supporting custom format options

You can also accept specifiers. For example, let `{:b}` mean a brief form and `{:f}` a full form:

```C++
#include <format>

class point
{
public:
  point(int x, int y) : x_(x), y_(y) {}

  [[nodiscard]] int x() const noexcept { return x_; }
  [[nodiscard]] int y() const noexcept { return y_; }

private:
  int x_;
  int y_;
};

template<> struct std::formatter<point>
{
  char presentation('b');

  [[nodiscard]] constexpr auto parse(std::format_parse_context &ctx)
  {
    auto it(ctx.begin());
    const auto end(ctx.end());

    if (it != end && *it != '}')
    {
      if (*it == 'b' || *it == 'f')
        presentation = *it++;
      else
        throw std::format_error("invalid format specifier");
    }

    if (it != end && *it != '}')
      throw std::format_error("invalid format specifier");

    return it;
  }

  [[nodiscard]] auto format(const point &p, std::format_context &ctx) const
  {
    if (presentation == 'f')
      return std::format_to(ctx.out(), "point[x={}, y={}]", p.x(), p.y());

    return std::format_to(ctx.out(), "({}, {})", p.x(), p.y());
  }
};
```

Usage:

```C++
point p(3, 7);

std::format("{}", p);     // "(3, 7)"
std::format("{:f}", p);   // "point[x=3, y=7]"
```


## A useful shortcut

If your class already has a natural string representation, you can delegate to an existing formatter, often `std::formatter<std::string_view>`:

```C++
#include <format>
#include <string>

class widget
{
public:
  explicit widget(std::string name) : name_(std::move(name)) {}

  [[nodiscard]] std::string to_string() const
  {
    return "widget[" + name_ + "]";
  }

private:
  std::string name_;
};

template<> struct std::formatter<widget> : std::formatter<std::string_view>
{
  // We don't need to define parse() because we inherit it
  // from std::formatter<std::string_view>!

  [[nodiscard]] auto format(const widget &w, std::format_context &ctx) const
  {
    // This now supports {:>10} or {:*^20} automatically.
    return std::formatter<std::string_view>::format(w.to_string(), ctx);
  }
};
```

This is often the cleanest solution when you do not need custom parsing.


## Common mistakes

- Forgetting the specialisation entirely. Without a `std::formatter<T>`, `std::format("{}", value)` cannot work.
- Returning the wrong iterator from `parse()`. `parse()` should return the iterator pointing at the closing `}` or the position just before formatting resumes.
- Ignoring invalid specifiers. If you accept custom options, reject unknown ones with `std::format_error`.
- Formatting via `operator<<`. `std::format` does not automatically use stream insertion operators; having: `std::ostream &operator<<(std::ostream &, const MyType &);` does not make the type formattable.


## More details

### std::format_parse_context

[`std::format_parse_context`](https://en.cppreference.com/w/cpp/utility/format/basic_format_parse_context.html) represents the format specifier part of a replacement field, everything inside `{...}` after the colon.

For example:

```C++
std::format("{:08.2f}", 3.14);
```

Inside your formatter, `parse_context` sees only:

```C++
"08.2f"
```

The key API is:

```C++
auto begin() const;
auto end() const;
```

These return iterators over the format specifier. So the typical usage is:

```C++
constexpr auto parse(std::format_parse_context &ctx)
{
  auto it(ctx.begin());
  auto end(ctx.end());

  if (it != end && *it != '}')
  {
    // parse custom options here
  }

  if (it != end && *it != '}')
    throw std::format_error("invalid format");

  return it;
}
```

** You must return an iterator pointing to where parsing stopped. Usually that's the `}`** (or just before it).

`parse()` runs once per format string, so you can store parsed options inside the formatter object:

```C++
char mode = 'd';  // stored between parse() and format()
```

### `std::format_context`

[`std::format_context`](https://en.cppreference.com/w/cpp/utility/format/basic_format_context.html) represents the output side of formatting.

It provides:

- the destination buffer;
- access to formatting arguments (rarely needed in custom formatters);

Its main role is to let you write formatted output.

The key API is

```C++
auto out();
```

This returns an output iterator that you can use if you want "full control":

```C++
auto out = ctx.out();
*out++ = '(';
out = std::format_to(out, "{}", p.x());
*out++ = ',';
*out++ = ' ';
out = std::format_to(out, "{}", p.y());
*out++ = ')';
return out;
```

but usually:

```C++
std::format_to(ctx.out(), "({}, {})", p.x(), p.y());
```

### Flow

```
"{:spec}" → parse_context → parse()
                                |
                                ▼
                         formatter state
                                |
                                ▼
value + format_context → format() → output
```
