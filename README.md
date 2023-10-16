# gmi-lexer
This is a simple project of a [Gemtext](http://geminiprotocol.net/docs/gemtext.gmi) lexer in Lua.

This isn't robust: if you give it unexpected types, you'll get undefined behavior (it'll probably just error out).

I made this because i wasn't feeling okay, and i use programming as a coping mechanism.

## using

* `Lexer.TypeId` is an "enum" containing string keys that distinguish what type of line / thing something is as an `Element`.
* `Element` is the superclass of all line types, they are logical types only and are defined in [LuaLS annotations](https://luals.github.io/wiki/annotations/). All elements have the `type` field, one of `TypeId`.
* `Lexer.iterFromIter(function() -> string | nil) -> function() Element | nil` returns an iterator that works on the output of another iterator, like `io.lines`.
* `Lexer.iterFromString(string) -> function() Element | nil` returns an iterator that lexes a whole string, entire thing as one singular string.
* `Lexer.iterFromLines(string[]) -> function() Element | nil` returns an iterator that lexes an array of individual lines.
* Additionally, see [lexer.lua](./lexer.lua) for info on individual types
* `Lexer.version` is a  major point minor version string. i don't think anyone would want to use this for realsies but hey.

## example

I also made a thing that reinterprets the stream of elements and outputs either a debug printout (with arg `--lexer`) or formatted nicely (80 column, with colors (unless with arg `--no-style`)). Run `lua cli.lua` for a demonstration.

