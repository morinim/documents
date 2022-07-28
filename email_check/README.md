# Email addresses validation

## Generalities

An email address has two parts:

- the **local-part**: everything to the left of the rightmost `@`;
- the **domain-part**: everything to the right of the rightmost `@`.

It's worth noting some things about these parts that aren't immediately obvious:

- the *local-part* can:
  - contain escaped characters and even additional `@` characters
  - be case sensitive (however it's up to the mail server at that specific domain how it wants to distinguish case)
- the *domain part* can contain zero or more labels separated by a period (`.`), though in practice there are no MX records corresponding to the root (zero labels) or on the gTLDs (one label) themselves.

## Secure checks

There're some checks you can do without rejecting valid email addresses that correspond with the above:

- address contains at least one `@`;
- the *local-part* is non-empty;
- the *domain-part* contains at least one period (again, this isn't strictly true but pragmatic).

That's it. The often pointed out best practice is to test deliverability to the address, so establishing two important things:

- whether the email currently exists;
- the user has access to the email address (is the legitimate user/owner).

## Validation via regular expressions

In general using regular expressions to validate email addresses is harmful. This is because of bad (incorrect) assumptions by the author of the regular expression.

Anyway a general email regex (in the [W3C HTML5 spec][HTML5]) is this:

```
^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
```

This expression is a *willful violation* of [RFC 5322][RFC5322], which:

> defines a syntax for email addresses that is simultaneously too strict (before the '@' character), too vague (after the '@' character), and too lax (allowing comments, whitespace characters, and quoted strings in manners unfamiliar to most users) to be of practical use.

In case the check fails, it's a good idea to ask the user to confirm their weird and wonderful corner case. Doing so politely, not as an error, won't raise any issue.

The expression used by `RegularExpressionValidator` (ASP.NET) is:

```
^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$
```

This fails on emails with *local-part* that ends in `-`, `+`, `.` and `'` (e.g.`simon-@hotmail.com`) and raises a very interesting point: you could not be able to send to some valid address using a particular server technology.

## C++ code

```c++
[[nodismiss]] const bool email_ok(const std::string &email)
{
  const std::regex
    pattern(R"(^[\w.!#$%&'*+\\/=?^`{|}~\-]+@[[:alnum:]](?:[[:alnum:]\-]{0,61}[[:alnum:]])?(?:\.[[:alnum:]](?:[[:alnum:]\-]{0,61}[[:alnum:]])?)*$)");

  return std::regex_match(email, pattern);
}
```

### References
- Stackoverflow: https://stackoverflow.com/a/48170419/3235496

[HTML5]: https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
[RFC5322]: https://html.spec.whatwg.org/multipage/references.html#refsRFC5322
