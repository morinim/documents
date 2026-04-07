# Linux compose key sequences

## Some rules

Despite the intimidating size of the full compose table, Linux compose sequences are actually quite systematic.
Once you internalise a handful of rules, most sequences become _guessable_ rather than memorised.

Below are general mental rules that cover the vast majority of entries.

### General compose pattern

Almost always:

> Compose → modifier → base character

Examples:

- Compose ' e → é
- Compose ^ o → ô
- Compose ~ n → ñ

Capital letters follow the same rule:

- Compose ' E → É
- Compose ~ N → Ñ

Think of the compose key as "apply this diacritic to the next letter".

### Ligatures are typed literally

Ligatures are exactly what they look like:

- Compose a e → æ
- Compose O E → Œ

### Strokes and slashes use /

Letters with a stroke almost always use /:

- Compose / O → Ø

### Superscripts and subscripts: ^ and _

Mathematical intuition applies (LaTeX-style):

- Superscript: Compose ^ 2 → ²
- Subscript: Compose _ 2 → ₂
- Superscript letters: Compose ^ n → ⁿ

### Currency signs use letters or symbols you expect

Currencies are mostly mnemonic:

- Compose L - → £
- Compose Y = → ¥
- Compose C = → €

### Minimal cheat sheet

If you only memorise four things, make it these:

- ' \ ^ ~ "` → accents
- _ ^ → subscript / superscript
- / → stroke
- letters typed literally for ligatures

Yes, this is _strongly_ biased — Italian user, US keyboard :-)

## What if I use Windows?

[Wincompose](https://github.com/samhocevar/wincompose) is a compose key for Windows, free and open-source created by Sam Hoevar.

## The complete table

(copied from archive of hermit.org)

This table shows the compose key sequences which can be used to enter accented and other non-standard characters in Linux.

To use these, you will first need to set up a compose key. Details may vary depending on your Linux setup, but it should be something like this:

- open the Control Centre / desktop configuration tool;
- select "Regional / Keyboard Layout";
- select "Xkb Options";
- scroll down to "Compose Key Position";
- select which key you would like to use as a compose key. The menu key works well for me.

Once you've set that up, you should be able to use the compose key sequences below by pressing Compose and the elements of the sequence. For example, to enter a Euro sign, you would type

```
<Compose> = C
```

(the Compose key, then the equals sign, then a capital C).

| Unicode | Char | Compose     | Comment                                  |
| ---     | ---  | ---         | ---                                      |
| U00a0   |      | "  "        | nobreakspace # NO-BREAK SPACE            |
| U00a1   | ¡    | !!          | exclamdown # INVERTED EXCLAMATION MARK   |
| U00a2   | ¢    | |c c| c/ /c | CENT SIGN                                |
| U00a3   | £    | L- -L       | POUND SIGN                               |
| U00a4   | ¤    | ox xo       | currency # CURRENCY SIGN                 |
| U00a5   | ¥    | Y= =Y       | yen # YEN SIGN                           |
| U00a6   | ¦    | !^          | brokenbar # BROKEN BAR                   |
| U00a7   | §    | so os       | section # SECTION SIGN                   |
| U00a9   | ©    | oc oC Oc OC | copyright # COPYRIGHT SIGN               |
| U00aa   | ª    | ^_a         | FEMININE ORDINAL INDICATOR               |
| U00ab   | «    | <<          | guillemotleft                            |
| U00ac   | ¬    | ,- -,       | NOT SIGN                                 |
| U00ae   | ®    | or oR Or OR | registered # REGISTERED SIGN             |
| U00b0   | °    | oo          | degree # DEGREE SIGN                     |
| U00b1   | ±    | +-          | plusminus # PLUS-MINUS SIGN              |
| U00b2   | ²    | ^2          | SUPERSCRIPT TWO                          |
| U00b3   | ³    | ^3          | SUPERSCRIPT THREE                        |
| U00b5   | µ    | mu          | MICRO SIGN                               |
| U00b6   | ¶    | p! P! PP    | paragraph # PILCROW SIGN                 |
| U00b7   | ·    | ..          | MIDDLE DOT                               |
| U00b8   | ¸    | ", " " ,"   | cedilla # CEDILLA                        |
| U00b9   | ¹    | ^1          | SUPERSCRIPT ONE                          |
| U00ba   | º    | ^_o         | MASCULINE ORDINAL INDICATOR              |
| U00bb   | »    | >>          | guillemotright                           |
| U00bc   | ¼    | 14          | VULGAR FRACTION ONE QUARTER              |
| U00bd   | ½    | 12          | VULGAR FRACTION ONE HALF                 |
| U00be   | ¾    | 34          | VULGAR FRACTION THREE QUARTERS           |
| U00bf   | ¿    | ??          | questiondown # INVERTED QUESTION MARK    |
| U00c0   | À    | `A          | LATIN CAPITAL LETTER A WITH GRAVE        |
| U00c1   | Á    | 'A          | LATIN CAPITAL LETTER A WITH ACUTE        |
| U00c2   | Â    | ^A          | LATIN CAPITAL LETTER A WITH CIRCUMFLEX   |
| U00c3   | Ã    | ~A          | LATIN CAPITAL LETTER A WITH TILDE        |
| U00c4   | Ä    | "A          | LATIN CAPITAL LETTER A WITH DIAERESIS    |
| U00c5   | Å    | oA          | LATIN CAPITAL LETTER A WITH RING ABOVE   |
| U00c6   | Æ    | AE          | AE # LATIN CAPITAL LETTER AE             |
| U00c7   | Ç    | ,C          | LATIN CAPITAL LETTER C WITH CEDILLA      |
| U00c8   | È    | `E          | LATIN CAPITAL LETTER E WITH GRAVE        |
| U00c9   | É    | 'E          | LATIN CAPITAL LETTER E WITH ACUTE        |
| U00ca   | Ê    | ^E          | LATIN CAPITAL LETTER E WITH CIRCUMFLEX   |
| U00cb   | Ë    | "E          | LATIN CAPITAL LETTER E WITH DIAERESIS    |
| U00cc   | Ì    | `I          | LATIN CAPITAL LETTER I WITH GRAVE        |
| U00cd   | Í    | 'I          | LATIN CAPITAL LETTER I WITH ACUTE        |
| U00ce   | Î    | ^I          | LATIN CAPITAL LETTER I WITH CIRCUMFLEX   |
| U00cf   | Ï    | "I          | LATIN CAPITAL LETTER I WITH DIAERESIS    |
| U00d0   | Ð    | DH          | LATIN CAPITAL LETTER ETH                 |
| U00d1   | Ñ    | ~N          | LATIN CAPITAL LETTER N WITH TILDE        |
| U00d2   | Ò    | `O          | LATIN CAPITAL LETTER O WITH GRAVE        |
| U00d3   | Ó    | 'O          | LATIN CAPITAL LETTER O WITH ACUTE        |
| U00d4   | Ô    | ^O          | LATIN CAPITAL LETTER O WITH CIRCUMFLEX   |
| U00d5   | Õ    | ~O          | LATIN CAPITAL LETTER O WITH TILDE        |
| U00d6   | Ö    | "O          | LATIN CAPITAL LETTER O WITH DIAERESIS    |
| U00d7   | ×    | xx          | MULTIPLICATION SIGN                      |
| U00d8   | Ø    | /O          | LATIN CAPITAL LETTER O WITH STROKE       |
| U00d9   | Ù    | `U          | LATIN CAPITAL LETTER U WITH GRAVE        |
| U00da   | Ú    | 'U          | LATIN CAPITAL LETTER U WITH ACUTE        |
| U00db   | Û    | ^U          | LATIN CAPITAL LETTER U WITH CIRCUMFLEX   |
| U00dc   | Ü    | "U          | LATIN CAPITAL LETTER U WITH DIAERESIS    |
| U00dd   | Ý    | 'Y          | LATIN CAPITAL LETTER Y WITH ACUTE        |
| U00de   | Þ    | TH          | LATIN CAPITAL LETTER THORN               |
| U00df   | ß    | ss          | LATIN SMALL LETTER SHARP S               |
| U00e0   | à    | `a          | LATIN SMALL LETTER A WITH GRAVE          |
| U00e1   | á    | 'a          | LATIN SMALL LETTER A WITH ACUTE          |
| U00e2   | â    | ^a          | LATIN SMALL LETTER A WITH CIRCUMFLEX     |
| U00e3   | ã    | ~a          | LATIN SMALL LETTER A WITH TILDE          |
| U00e4   | ä    | "a          | LATIN SMALL LETTER A WITH DIAERESIS      |
| U00e5   | å    | oa          | LATIN SMALL LETTER A WITH RING ABOVE     |
| U00e6   | æ    | ae          | LATIN SMALL LETTER AE                    |
| U00e7   | ç    | ,c          | LATIN SMALL LETTER C WITH CEDILLA        |
| U00e8   | è    | `e          | LATIN SMALL LETTER E WITH GRAVE          |
| U00e9   | é    | 'e          | LATIN SMALL LETTER E WITH ACUTE          |
| U00ea   | ê    | ^e          | LATIN SMALL LETTER E WITH CIRCUMFLEX     |
| U00eb   | ë    | "e          | LATIN SMALL LETTER E WITH DIAERESIS      |
| U00ec   | ì    | `i          | LATIN SMALL LETTER I WITH GRAVE          |
| U00ed   | í    | 'i          | LATIN SMALL LETTER I WITH ACUTE          |
| U00ee   | î    | ^i          | LATIN SMALL LETTER I WITH CIRCUMFLEX     |
| U00ef   | ï    | "i          | LATIN SMALL LETTER I WITH DIAERESIS      |
| U00f0   | ð    | dh          | LATIN SMALL LETTER ETH                   |
| U00f1   | ñ    | ~n          | LATIN SMALL LETTER N WITH TILDE          |
| U00f2   | ò    | `o          | LATIN SMALL LETTER O WITH GRAVE          |
| U00f3   | ó    | 'o          | LATIN SMALL LETTER O WITH ACUTE          |
| U00f4   | ô    | ^o          | LATIN SMALL LETTER O WITH CIRCUMFLEX     |
| U00f5   | õ    | ~o          | LATIN SMALL LETTER O WITH TILDE          |
| U00f6   | ö    | "o          | LATIN SMALL LETTER O WITH DIAERESIS      |
| U00f7   | ÷    | :- -:       | DIVISION SIGN                            |
| U00f8   | ø    | /o          | LATIN SMALL LETTER O WITH STROKE         |
| U00f9   | ù    | `u          | LATIN SMALL LETTER U WITH GRAVE          |
| U00fa   | ú    | 'u          | LATIN SMALL LETTER U WITH ACUTE          |
| U00fb   | û    | ^u          | LATIN SMALL LETTER U WITH CIRCUMFLEX     |
| U00fc   | ü    | "u          | LATIN SMALL LETTER U WITH DIAERESIS      |
| U00fd   | ý    | 'y          | LATIN SMALL LETTER Y WITH ACUTE          |
| U00fe   | þ    | th          | LATIN SMALL LETTER THORN                 |
| U00ff   | ÿ    | "y          | LATIN SMALL LETTER Y WITH DIAERESIS      |
| U0100   | Ā    | _A          | LATIN CAPITAL LETTER A WITH MACRON       |
| U0101   | ā    | _a          | LATIN SMALL LETTER A WITH MACRON         |
| U0102   | Ă    | UA bA       | LATIN CAPITAL LETTER A WITH BREVE        |
| U0103   | ă    | Ua ba       | LATIN SMALL LETTER A WITH BREVE          |
| U0104   | Ą    | ;A          | LATIN CAPITAL LETTER A WITH OGONEK       |
| U0105   | ą    | ;a          | LATIN SMALL LETTER A WITH OGONEK         |
| U0106   | Ć    | 'C          | LATIN CAPITAL LETTER C WITH ACUTE        |
| U0107   | ć    | 'c          | LATIN SMALL LETTER C WITH ACUTE          |
| U0108   | Ĉ    | ^C          | LATIN CAPITAL LETTER C WITH CIRCUMFLEX   |
| U0109   | ĉ    | ^c          | LATIN SMALL LETTER C WITH CIRCUMFLEX     |
| U010c   | Č    | cC          | LATIN CAPITAL LETTER C WITH CARON        |
| U010d   | č    | cc          | LATIN SMALL LETTER C WITH CARON          |
| U010e   | Ď    | cD          | LATIN CAPITAL LETTER D WITH CARON        |
| U010f   | ď    | cd          | LATIN SMALL LETTER D WITH CARON          |
| U0110   | Đ    | -D /D       | LATIN CAPITAL LETTER D WITH STROKE       |
| U0111   | đ    | -d /d       | LATIN SMALL LETTER D WITH STROKE         |
| U0112   | Ē    | _E          | LATIN CAPITAL LETTER E WITH MACRON       |
| U0113   | ē    | _e          | LATIN SMALL LETTER E WITH MACRON         |
| U0114   | Ĕ    | UE bE       | LATIN CAPITAL LETTER E WITH BREVE        |
| U0115   | ĕ    | Ue be       | LATIN SMALL LETTER E WITH BREVE          |
| U0118   | Ę    | ;E          | LATIN CAPITAL LETTER E WITH OGONEK       |
| U0119   | ę    | ;e          | LATIN SMALL LETTER E WITH OGONEK         |
| U011a   | Ě    | cE          | LATIN CAPITAL LETTER E WITH CARON        |
| U011b   | ě    | ce          | LATIN SMALL LETTER E WITH CARON          |
| U011c   | Ĝ    | ^G          | LATIN CAPITAL LETTER G WITH CIRCUMFLEX   |
| U011d   | ĝ    | ^g          | LATIN SMALL LETTER G WITH CIRCUMFLEX     |
| U011e   | Ğ    | UG bG       | LATIN CAPITAL LETTER G WITH BREVE        |
| U011f   | ğ    | Ug bg       | LATIN SMALL LETTER G WITH BREVE          |
| U0122   | Ģ    | ,G          | LATIN CAPITAL LETTER G WITH CEDILLA      |
| U0123   | ģ    | ,g          | LATIN SMALL LETTER G WITH CEDILLA        |
| U0124   | Ĥ    | ^H          | LATIN CAPITAL LETTER H WITH CIRCUMFLEX   |
| U0125   | ĥ    | ^h          | LATIN SMALL LETTER H WITH CIRCUMFLEX     |
| U0126   | Ħ    | /H          | LATIN CAPITAL LETTER H WITH STROKE       |
| U0127   | ħ    | /h          | LATIN SMALL LETTER H WITH STROKE         |
| U0128   | Ĩ    | ~I          | LATIN CAPITAL LETTER I WITH TILDE        |
| U0129   | ĩ    | ~i          | LATIN SMALL LETTER I WITH TILDE          |
| U012a   | Ī    | _I          | LATIN CAPITAL LETTER I WITH MACRON       |
| U012b   | ī    | _i          | LATIN SMALL LETTER I WITH MACRON         |
| U012c   | Ĭ    | UI bI       | LATIN CAPITAL LETTER I WITH BREVE        |
| U012d   | ĭ    | Ui bi       | LATIN SMALL LETTER I WITH BREVE          |
| U012e   | Į    | ;I          | LATIN CAPITAL LETTER I WITH OGONEK       |
| U012f   | į    | ;i          | LATIN SMALL LETTER I WITH OGONEK         |
| U0131   | ı    | i.          | LATIN SMALL LETTER DOTLESS I             |
| U0134   | Ĵ    | ^J          | LATIN CAPITAL LETTER J WITH CIRCUMFLEX   |
| U0135   | ĵ    | ^j          | LATIN SMALL LETTER J WITH CIRCUMFLEX     |
| U0136   | Ķ    | ,K          | LATIN CAPITAL LETTER K WITH CEDILLA      |
| U0137   | ķ    | ,k          | LATIN SMALL LETTER K WITH CEDILLA        |
| U0138   | ĸ    | kk          | LATIN SMALL LETTER KRA                   |
| U0139   | Ĺ    | 'L          | LATIN CAPITAL LETTER L WITH ACUTE        |
| U013a   | ĺ    | 'l          | LATIN SMALL LETTER L WITH ACUTE          |
| U013b   | Ļ    | ,L          | LATIN CAPITAL LETTER L WITH CEDILLA      |
| U013c   | ļ    | ,l          | LATIN SMALL LETTER L WITH CEDILLA        |
| U013d   | Ľ    | cL          | LATIN CAPITAL LETTER L WITH CARON        |
| U013e   | ľ    | cl          | LATIN SMALL LETTER L WITH CARON          |
| U0141   | Ł    | /L          | LATIN CAPITAL LETTER L WITH STROKE       |
| U0142   | ł    | /l          | LATIN SMALL LETTER L WITH STROKE         |
| U0143   | Ń    | 'N          | LATIN CAPITAL LETTER N WITH ACUTE        |
| U0144   | ń    | 'n          | LATIN SMALL LETTER N WITH ACUTE          |
| U0145   | Ņ    | ,N          | LATIN CAPITAL LETTER N WITH CEDILLA      |
| U0146   | ņ    | ,n          | LATIN SMALL LETTER N WITH CEDILLA        |
| U0147   | Ň    | cN          | LATIN CAPITAL LETTER N WITH CARON        |
| U0148   | ň    | cn          | LATIN SMALL LETTER N WITH CARON          |
| U014a   | Ŋ    | NG          | LATIN CAPITAL LETTER ENG                 |
| U014b   | ŋ    | ng          | LATIN SMALL LETTER ENG                   |
| U014c   | Ō    | _O          | LATIN CAPITAL LETTER O WITH MACRON       |
| U014d   | ō    | _o          | LATIN SMALL LETTER O WITH MACRON         |
| U014e   | Ŏ    | UO bO       | LATIN CAPITAL LETTER O WITH BREVE        |
| U014f   | ŏ    | Uo bo       | LATIN SMALL LETTER O WITH BREVE          |
| U0150   | Ő    | =O          | LATIN CAPITAL LETTER O WITH DOUBLE ACUTE |
| U0151   | ő    | =o          | LATIN SMALL LETTER O WITH DOUBLE ACUTE   |
| U0152   | Œ    | OE          | LATIN CAPITAL LIGATURE OE                |
| U0153   | œ    | oe          | LATIN SMALL LIGATURE OE                  |
| U0154   | Ŕ    | 'R          | LATIN CAPITAL LETTER R WITH ACUTE        |
| U0155   | ŕ    | 'r          | LATIN SMALL LETTER R WITH ACUTE          |
| U0156   | Ŗ    | ,R          | LATIN CAPITAL LETTER R WITH CEDILLA      |
| U0157   | ŗ    | ,r          | LATIN SMALL LETTER R WITH CEDILLA        |
| U0158   | Ř    | cR          | LATIN CAPITAL LETTER R WITH CARON        |
| U0159   | ř    | cr          | LATIN SMALL LETTER R WITH CARON          |
| U015a   | Ś    | 'S          | LATIN CAPITAL LETTER S WITH ACUTE        |
| U015b   | ś    | 's          | LATIN SMALL LETTER S WITH ACUTE          |
| U015c   | Ŝ    | ^S          | LATIN CAPITAL LETTER S WITH CIRCUMFLEX   |
| U015d   | ŝ    | ^s          | LATIN SMALL LETTER S WITH CIRCUMFLEX     |
| U015e   | Ş    | ,S          | LATIN CAPITAL LETTER S WITH CEDILLA      |
| U015f   | ş    | ,s          | LATIN SMALL LETTER S WITH CEDILLA        |
| U0160   | Š    | cS          | LATIN CAPITAL LETTER S WITH CARON        |
| U0161   | š    | cs          | LATIN SMALL LETTER S WITH CARON          |
| U0162   | Ţ    | ,T          | LATIN CAPITAL LETTER T WITH CEDILLA      |
| U0163   | ţ    | ,t          | LATIN SMALL LETTER T WITH CEDILLA        |
| U0164   | Ť    | cT          | LATIN CAPITAL LETTER T WITH CARON        |
| U0165   | ť    | ct          | LATIN SMALL LETTER T WITH CARON          |
| U0166   | Ŧ    | /T          | LATIN CAPITAL LETTER T WITH STROKE       |
| U0167   | ŧ    | /t          | LATIN SMALL LETTER T WITH STROKE         |
| U0168   | Ũ    | ~U          | LATIN CAPITAL LETTER U WITH TILDE        |
| U0169   | ũ    | ~u          | LATIN SMALL LETTER U WITH TILDE          |
| U016a   | Ū    | _U          | LATIN CAPITAL LETTER U WITH MACRON       |
| U016b   | ū    | _u          | LATIN SMALL LETTER U WITH MACRON         |
| U016c   | Ŭ    | UU bU       | LATIN CAPITAL LETTER U WITH BREVE        |
| U016d   | ŭ    | Uu bu       | LATIN SMALL LETTER U WITH BREVE          |
| U016e   | Ů    | oU          | LATIN CAPITAL LETTER U WITH RING ABOVE   |
| U016f   | ů    | ou          | LATIN SMALL LETTER U WITH RING ABOVE     |
| U0170   | Ű    | =U          | LATIN CAPITAL LETTER U WITH DOUBLE ACUTE |
| U0171   | ű    | =u          | LATIN SMALL LETTER U WITH DOUBLE ACUTE   |
| U0172   | Ų    | ;U          | LATIN CAPITAL LETTER U WITH OGONEK       |
| U0173   | ų    | ;u          | LATIN SMALL LETTER U WITH OGONEK         |
| U0174   | Ŵ    | ^W          | LATIN CAPITAL LETTER W WITH CIRCUMFLEX   |
| U0175   | ŵ    | ^w          | LATIN SMALL LETTER W WITH CIRCUMFLEX     |
| U0176   | Ŷ    | ^Y          | LATIN CAPITAL LETTER Y WITH CIRCUMFLEX   |
| U0177   | ŷ    | ^y          | LATIN SMALL LETTER Y WITH CIRCUMFLEX     |
| U0178   | Ÿ    | "Y          | LATIN CAPITAL LETTER Y WITH DIAERESIS    |
| U0179   | Ź    | 'Z          | LATIN CAPITAL LETTER Z WITH ACUTE        |
| U017a   | ź    | 'z          | LATIN SMALL LETTER Z WITH ACUTE          |
| U017d   | Ž    | cZ          | LATIN CAPITAL LETTER Z WITH CARON        |
| U017e   | ž    | cz          | LATIN SMALL LETTER Z WITH CARON          |
| U017f   | ſ    | fs fS       | LATIN SMALL LETTER LONG S                |
| U0180   | ƀ    | /b          | LATIN SMALL LETTER B WITH STROKE         |
| U0197   | Ɨ    | /I          | LATIN CAPITAL LETTER I WITH STROKE       |
| U01b5   | Ƶ    | /Z          | LATIN CAPITAL LETTER Z WITH STROKE       |
| U01b6   | ƶ    | /z          | LATIN SMALL LETTER Z WITH STROKE         |
| U01cd   | Ǎ    | cA          | LATIN CAPITAL LETTER A WITH CARON        |
| U01ce   | ǎ    | ca          | LATIN SMALL LETTER A WITH CARON          |
| U01cf   | Ǐ    | cI          | LATIN CAPITAL LETTER I WITH CARON        |
| U01d0   | ǐ    | ci          | LATIN SMALL LETTER I WITH CARON          |
| U01d1   | Ǒ    | cO          | LATIN CAPITAL LETTER O WITH CARON        |
| U01d2   | ǒ    | co          | LATIN SMALL LETTER O WITH CARON          |
| U01d3   | Ǔ    | cU          | LATIN CAPITAL LETTER U WITH CARON        |
| U01d4   | ǔ    | cu          | LATIN SMALL LETTER U WITH CARON          |
| U01e6   | Ǧ    | cG          | LATIN CAPITAL LETTER G WITH CARON        |
| U01e7   | ǧ    | cg          | LATIN SMALL LETTER G WITH CARON          |
| U01e8   | Ǩ    | cK          | LATIN CAPITAL LETTER K WITH CARON        |
| U01e9   | ǩ    | ck          | LATIN SMALL LETTER K WITH CARON          |
| U01ea   | Ǫ    | ;O          | LATIN CAPITAL LETTER O WITH OGONEK       |
| U01eb   | ǫ    | ;o          | LATIN SMALL LETTER O WITH OGONEK         |
| U01f0   | ǰ    | cj          | LATIN SMALL LETTER J WITH CARON          |
| U01f4   | Ǵ    | 'G          | LATIN CAPITAL LETTER G WITH ACUTE        |
| U01f5   | ǵ    | 'g          | LATIN SMALL LETTER G WITH ACUTE          |
| U01f8   | Ǹ    | `N          | LATIN CAPITAL LETTER N WITH GRAVE        |
| U01f9   | ǹ    | `n          | LATIN SMALL LETTER N WITH GRAVE          |
| U021e   | Ȟ    | cH          | LATIN CAPITAL LETTER H WITH CARON        |
| U021f   | ȟ    | ch          | LATIN SMALL LETTER H WITH CARON          |
| U0228   | Ȩ    | ,E          | LATIN CAPITAL LETTER E WITH CEDILLA      |
| U0229   | ȩ    | ,e          | LATIN SMALL LETTER E WITH CEDILLA        |
| U0232   | Ȳ    | _Y          | LATIN CAPITAL LETTER Y WITH MACRON       |
| U0233   | ȳ    | _y          | LATIN SMALL LETTER Y WITH MACRON         |
| U0259   | ə    | ee          | LATIN SMALL LETTER SCHWA                 |
| U0268   | ɨ    | /i          | LATIN SMALL LETTER I WITH STROKE         |
| U1e10   | Ḑ    | ,D          | LATIN CAPITAL LETTER D WITH CEDILLA      |
| U1e11   | ḑ    | ,d          | LATIN SMALL LETTER D WITH CEDILLA        |
| U1e20   | Ḡ    | _G          | LATIN CAPITAL LETTER G WITH MACRON       |
| U1e21   | ḡ    | _g          | LATIN SMALL LETTER G WITH MACRON         |
| U1e26   | Ḧ    | "H          | LATIN CAPITAL LETTER H WITH DIAERESIS    |
| U1e27   | ḧ    | "h          | LATIN SMALL LETTER H WITH DIAERESIS      |
| U1e28   | Ḩ    | ,H          | LATIN CAPITAL LETTER H WITH CEDILLA      |
| U1e29   | ḩ    | ,h          | LATIN SMALL LETTER H WITH CEDILLA        |
| U1e30   | Ḱ    | 'K          | LATIN CAPITAL LETTER K WITH ACUTE        |
| U1e31   | ḱ    | 'k          | LATIN SMALL LETTER K WITH ACUTE          |
| U1e3e   | Ḿ    | 'M          | LATIN CAPITAL LETTER M WITH ACUTE        |
| U1e3f   | ḿ    | 'm          | LATIN SMALL LETTER M WITH ACUTE          |
| U1e54   | Ṕ    | 'P          | LATIN CAPITAL LETTER P WITH ACUTE        |
| U1e55   | ṕ    | 'p          | LATIN SMALL LETTER P WITH ACUTE          |
| U1e7c   | Ṽ    | ~V          | LATIN CAPITAL LETTER V WITH TILDE        |
| U1e7d   | ṽ    | ~v          | LATIN SMALL LETTER V WITH TILDE          |
| U1e80   | Ẁ    | `W          | LATIN CAPITAL LETTER W WITH GRAVE        |
| U1e81   | ẁ    | `w          | LATIN SMALL LETTER W WITH GRAVE          |
| U1e82   | Ẃ    | 'W          | LATIN CAPITAL LETTER W WITH ACUTE        |
| U1e83   | ẃ    | 'w          | LATIN SMALL LETTER W WITH ACUTE          |
| U1e84   | Ẅ    | "W          | LATIN CAPITAL LETTER W WITH DIAERESIS    |
| U1e85   | ẅ    | "w          | LATIN SMALL LETTER W WITH DIAERESIS      |
| U1e8c   | Ẍ    | "X          | LATIN CAPITAL LETTER X WITH DIAERESIS    |
| U1e8d   | ẍ    | "x          | LATIN SMALL LETTER X WITH DIAERESIS      |
| U1e90   | Ẑ    | ^Z          | LATIN CAPITAL LETTER Z WITH CIRCUMFLEX   |
| U1e91   | ẑ    | ^z          | LATIN SMALL LETTER Z WITH CIRCUMFLEX     |
| U1e97   | ẗ    | "t          | LATIN SMALL LETTER T WITH DIAERESIS      |
| U1e98   | ẘ    | ow          | LATIN SMALL LETTER W WITH RING ABOVE     |
| U1e99   | ẙ    | oy          | LATIN SMALL LETTER Y WITH RING ABOVE     |
| U1ebc   | Ẽ    | ~E          | LATIN CAPITAL LETTER E WITH TILDE        |
| U1ebd   | ẽ    | ~e          | LATIN SMALL LETTER E WITH TILDE          |
| U1ef2   | Ỳ    | `Y          | LATIN CAPITAL LETTER Y WITH GRAVE        |
| U1ef3   | ỳ    | `y          | LATIN SMALL LETTER Y WITH GRAVE          |
| U1ef8   | Ỹ    | ~Y          | LATIN CAPITAL LETTER Y WITH TILDE        |
| U1ef9   | ỹ    | ~y          | LATIN SMALL LETTER Y WITH TILDE          |
| U2008   |      | " ."        | PUNCTUATION SPACE                        |
| U2013   | –    | --.         | EN DASH                                  |
| U2014   | —    | ---         | EM DASH                                  |
| U2018   | ‘    | <' '<       | LEFT SINGLE QUOTATION MARK               |
| U2019   | ’    | >' '>       | RIGHT SINGLE QUOTATION MARK              |
| U201a   | ‚    | ,' ',       | SINGLE LOW-9 QUOTATION MARK              |
| U201c   | “    | <" "<       | LEFT DOUBLE QUOTATION MARK               |
| U201d   | ”    | >" ">       | RIGHT DOUBLE QUOTATION MARK              |
| U201e   | „    | ," ",       | DOUBLE LOW-9 QUOTATION MARK              |
| U2030   | ‰    | %o          | PER MILLE SIGN                           |
| U2039   | ‹    | .<          | SINGLE LEFT-POINTING ANGLE QUOTATION MARK|
| U203a   | ›    | .>          | SINGLE RIGHT-POINTING ANGLE QUOTATION MARK|
| U2070   | ⁰    | ^0          | SUPERSCRIPT ZERO                         |
| U2071   | ⁱ    | ^_i         | SUPERSCRIPT LATIN SMALL LETTER I         |
| U2074   | ⁴    | ^4          | SUPERSCRIPT FOUR                         |
| U2075   | ⁵    | ^5          | SUPERSCRIPT FIVE                         |
| U2076   | ⁶    | ^6          | SUPERSCRIPT SIX                          |
| U2077   | ⁷    | ^7          | SUPERSCRIPT SEVEN                        |
| U2078   | ⁸    | ^8          | SUPERSCRIPT EIGHT                        |
| U2079   | ⁹    | ^9          | SUPERSCRIPT NINE                         |
| U207a   | ⁺    | ^+          | SUPERSCRIPT PLUS SIGN                    |
| U207c   | ⁼    | ^=          | SUPERSCRIPT EQUALS SIGN                  |
| U207d   | ⁽    | ^(          | SUPERSCRIPT LEFT PARENTHESIS             |
| U207e   | ⁾    | ^)          | SUPERSCRIPT RIGHT PARENTHESIS            |
| U207f   | ⁿ    | ^_n         | SUPERSCRIPT LATIN SMALL LETTER N         |
| U2080   | ₀    | _0          | SUBSCRIPT ZERO                           |
| U2081   | ₁    | _1          | SUBSCRIPT ONE                            |
| U2082   | ₂    | _2          | SUBSCRIPT TWO                            |
| U2083   | ₃    | _3          | SUBSCRIPT THREE                          |
| U2084   | ₄    | _4          | SUBSCRIPT FOUR                           |
| U2085   | ₅    | _5          | SUBSCRIPT FIVE                           |
| U2086   | ₆    | _6          | SUBSCRIPT SIX                            |
| U2087   | ₇    | _7          | SUBSCRIPT SEVEN                          |
| U2088   | ₈    | _8          | SUBSCRIPT EIGHT                          |
| U2089   | ₉    | _9          | SUBSCRIPT NINE                           |
| U208a   | ₊    | _+          | SUBSCRIPT PLUS SIGN                      |
| U208c   | ₌    | _=          | SUBSCRIPT EQUALS SIGN                    |
| U208d   | ₍    | _(          | SUBSCRIPT LEFT PARENTHESIS               |
| U208e   | ₎    | _)          | SUBSCRIPT RIGHT PARENTHESIS              |
| U20a0   | ₠    | CE          | EURO-CURRENCY SIGN                       |
| U20a1   | ₡    | C/ /C       | COLON SIGN                               |
| U20a2   | ₢    | Cr          | CRUZEIRO SIGN                            |
| U20a3   | ₣    | Fr          | FRENCH FRANC SIGN                        |
| U20a4   | ₤    | L= =L       | LIRA SIGN                                |
| U20a5   | ₥    | m/ /m       | MILL SIGN                                |
| U20a6   | ₦    | N= =N       | NAIRA SIGN                               |
| U20a7   | ₧    | Pt          | PESETA SIGN                              |
| U20a8   | ₨    | Rs          | RUPEE SIGN                               |
| U20a9   | ₩    | W= =W       | WON SIGN                                 |
| U20ab   | ₫    | d-          | DONG SIGN                                |
| U20ac   | €    | c= =c E= =E | EURO SIGN                                |
| U2120   | ℠   | ^SM         | SERVICE MARK                             |
| U2122   | ™    | ^TM         | TRADE MARK SIGN                          |
| U301d   |〝    | "\          | REVERSED DOUBLE PRIME QUOTATION MARK     |
| U301e   | 〞   | "/          | DOUBLE PRIME QUOTATION MARK              |
