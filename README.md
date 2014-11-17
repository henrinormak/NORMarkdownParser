NORMarkdownParser
=================

A lightweight wrapper around the [hoedown](https://github.com/hoedown/hoedown) Markdown parser, turning Markdown into `NSAttributedString`. The biggest difference between `NORMarkdownParser` and other parsers out there is the way the resulting string is stored. While other parsers tend to produce HTML strings, `NORMarkdownParser` results in a native `NSAttributedString` along with a stripped version of the string, making it more suitable for use in user interfaces that don't necessarily know how to render HTML (`UILabel`, `UITextField` any custom controls etc.)

`NORMarkdownParser` currently supports a limited subset of Markdown, more suitable for simpler applications that don't want/need to support the full extent of Markdown.

Supported aspects of Markdown
* Links (+ Autolinks as extension)
* Emphasis (single, double, triple)
* Underline (as an extension)
* Strikethrough (as an extension)
* Highlight (as an extension)
* Code (+ Fenced blocks as an extension)

Plans
-----

The project is very much in progress:

1. The parser needs tests, along with a multitude of examples
2. The parser could introduce a new extension for emoticon/emoji, something like `:smile:`, this would most likely require forking hoedown. Plan would be to support [this approach to emoji](http://www.emoji-cheat-sheet.com), meaning the parser would by default detect the emoji and the style would replace the code with the UTF representation, similar to what GitHub and the others do.

Pull requests for above or for other features/fixes are very welcome.

Contact
-------

If you have any questions, don't hesitate to contact me. 
In case of bugs, create an issue here on GitHub

Henri Normak

- http://github.com/henrinormak
- http://twitter.com/henrinormak


License
-------

```
The MIT License (MIT)

Copyright (c) 2014 Henri Normak

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
