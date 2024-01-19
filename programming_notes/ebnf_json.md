```ebnf
<json> ::= <primitive> | <container>.

<primitive> ::= <number> | <string> | <boolean>.
; Where:
; <number> is a valid real number expressed in one of a number of given formats
; <boolean> is one of the literal strings 'true', 'false', or 'null' (unquoted)

<container> ::= <object> | <array>.
<array> ::= '[' [ <json> *(', ' <json>) ] ']'. ; A sequence of JSON values separated by commas
<object> ::= '{' [ <member> *(', ' <member>) ] '}'. ; A sequence of 'members'
<member> ::= <string> ': ' <json>. ; A pair consisting of a name, and a JSON value

; Strings must be quoted with double quotes. Double quotes inside a string must be escaped.
; "\u" must be followed by four-hex-digits.
<string> ::= '"' <string sequence> '"'.
<string sequence> ::= {<string character>}.
<string character> ::= <any Unicode character excluding " and \> | '\"' | "\\" | "\/" | "\b" | "\f" | "\n" | "\r" | "\t" | "\u".

; JSON numbers follow JavaScript’s double-precision floating-point format.
; Represented in base 10 with no superfluous leading zeros (e.g. 67, 1, 100).
; Include digits between 0 and 9, can be a negative number (e.g. -10), can be a fraction (e.g. .5).
; Can also have an exponent of 10, prefixed by e or E with a plus or minus sign to indicate positive or negative exponentiation.
; Octal and hexadecimal formats are not supported. Can not have a value of NaN (Not A Number) or Infinity.
<number> ::= [<sign>] <unsigned number>.
<sign> ::= "+" | "-".
<unsigned number> ::= <unsigned integer> "." <unsigned integer> [<expo> <scale factor>] | <unsigned integer> <expo> <scale factor>.
<expo> ::= "E" | "e".
<scale factor> ::= <integer number>.
<integer number> ::= <sign> <unsigned integer>.
<unsigned integer> ::= <digit> {<digit>}.
<digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9".
```

## References
- [The JavaScript Object Notation (JSON) Data Interchange Format (RFC719)](https://www.rfc-editor.org/rfc/rfc7159)
- [Backus-Naur Form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form)
