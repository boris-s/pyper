# Pyper

Pyper is a wide extension of the Lispy car/cdr idea.

## Usage

Everybody knows Lispy functions `#car`, `#cdr`, `#caar`, `#cdar`, `#cadr`, `#cddr`...
With Pyper, you have them at the hand:
```ruby
require 'pyper'

[1, 2, 3].car # will return the first element, 1
[1, 2, 3].cdr # will return the remaining elements, [2, 3]
```

Similarly, `#caar` will return the first element of the first element, `#cadr`
will return the first element of the remaining elements (that is, second
element), #cddr will return the list of [3rd, 4th, ... ] elements, etc.

In Lisp, these compositions can theoretically extend ad infinitum:

caaar, caadr, cadar,...
caaaar, caaadr, ...
caaaaar, ..., cadaadr, ...

In effect, such character sequences form an APL-like language consisting of
one-character operators 'a' and 'd', whose combination determines the overall
operation. Pyper adds a few modifications and extends the idea:

1. Twin-barrel piping: Instead of just one pipeline, in which the
operations are applied in sequence, Pyper has 2 parallel pipelines.

2. Greek letters τ, π, χ as method delimiters: Instead of 'c' and 'r' of
car/cdr family, Pyper methods start and end with any of the characters
`τ`, `π`, `χ` (tau, pi and chi). Their meaning is best explained by an example:

`τ...τ` means single-pipe input and output,
`τ...π` means single-pipe input, double-pipe output
`τ...χ` means single-pipe input, double-pipe output with a swap
`π...τ` means double-pipe input, single-pipe output
 . . .
`χ...χ` means double-pipe input with a swap, and same for the output

(Mnemonic for this is, that τ has one (vertical) pipe, π has two pipes,
and χ looks like two pipes crossed)

As for the meaning, single-pipe input means, that a single object (the
message receiver) is fed to the pipeline. Double-pipe input means, that
the receiver is assumed to respond to methods #size and #[], its size is
2, and this being fulfilled, pipeline 0 and 1 are initialized
respectively with the first and second element of the receiver as per
method #[]. Double-pipe input with swap is the same, but the two
elements of the receiver are swapped: pipeline 1 receives the first,
pipeline 0 the second.

3. Postfix order of commands: While traditional car/cdr family of
methods applies the letters in the prefix order (from right to left),
Pyper uses postfix order (left to right).

Example: #cdar becomes τadτ ('da' reversed to 'ad')
         #cadaar becomes τaadaτ ('adaa' reversed to 'aada')

4. Extended set of commands: The set of command characters, which in the
traditional car/cdr method family consists only of two characters, 'a'
and 'd', is greatly extended.

For example, apart from 'a', mening first, 'b' means second, and 'c'
means third:
```ruby
["See", "you", "later", "alligator"].τaτ    #=>    "See"
["See", "you", "later", "alligator"].τbτ    #=>    "you"
["See", "you", "later", "alligator"].τcτ    #=>    "later"
```

For another example, apart from 'd', meaning all except first, 'e' means
all except first two, and 'f' means all except first three:
```ruby
["See", "you", "later", "alligator"].τdτ #=> ["you", "later", "alligator"]
["See", "you", "later", "alligator"].τeτ #=> ["later", "alligator"]
["See", "you", "later", "alligator"].τfτ #=> ["alligator"]
```

These command characters can be combined just like 'a' and 'd' letters
in the traditional car/cdr family - just beware of the Pyper's postfix
order:
```ruby
["See", "you", "later", "alligator"].τddτ #=> ["later", "alligator"]
["See", "you", "later", "alligator"].τdeτ #=> ["alligator"]
["See", "you", "later", "alligator"].τdeaτ #=> "alligator"
["See", "you", "later", "alligator"].τdeadτ #=> "lligator"
["See", "you", "later", "alligator"].τdeafτ #=> "igator"
["See", "you", "later", "alligator"].τdeafbτ #=> "g"
```

Allready with these few command characters (a-c, d-f, u-w, x-z, plus
numbers 0-4 and 5-9), one can compose intelligent car/cdr-like methods.
But there are more command characters available, representing various
common Ruby methods, operators etc.

5. Method arguments are possible: Unlike the traditional car/cdr family,
Pyper methods accept arguments. Regardless of the combination of the
command characters, any Pyper method can accept an arbitrary number of
arguments, which are [collected] into the 'args' variable, from which
the methods triggered by the command characters may take their arguments
as their arity requires.

******************************************************************

So much for the main concepts. As for the character meanings, those are
defined as PostfixMachine methods of the same name (the name consists of
1 or 2 characters). At the moment, it is necessary to read the code for
their documentation.
