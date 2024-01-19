```
<json> ::= <primitive> | <container>

<primitive> ::= <number> | <string> | <boolean>
; Where:
; <number> is a valid real number expressed in one of a number of given formats
; <string> is a string of valid characters enclosed in quotes
; <boolean> is one of the literal strings 'true', 'false', or 'null' (unquoted)

<container> ::= <object> | <array>
<array> ::= '[' [ <json> *(', ' <json>) ] ']' ; A sequence of JSON values separated by commas
<object> ::= '{' [ <member> *(', ' <member>) ] '}' ; A sequence of 'members'
<member> ::= <string> ': ' <json> ; A pair consisting of a name, and a JSON value

; Strings must be quoted with double quotes
<string> ::= '"' <string sequence> '"'.
<string sequence> ::= {<string character>}.
<string character> ::= <any Unicode character excluding " and \> | '\"' | "\\" | "\/" | "\b" | "\f" | "\n" | "\r" | "\t" | "\u".
```

## References
- [The JavaScript Object Notation (JSON) Data Interchange Format (RFC719)](https://www.rfc-editor.org/rfc/rfc7159)
