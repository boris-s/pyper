#coding: utf-8

require_relative 'pyper/version'
require_relative 'pyper/postfix_machine'

# Pyper is an extension of the Lispy car/cdr idea.
# 
module Pyper
  # Everybody knows Lispy functions #car, #cdr. In Ruby, these functions
  # can be defined for example as:
  def car; first end                                 # a: first
  def cdr; drop 1 end                                # d: all except first
  
  # In their basic form, they are only marginally useful.
  # Their popularity stems from their compositions:
  def caar; first.first end
  def cdar; first.drop 1 end
  def cadr; drop(1).first end
  def cddr; drop(1).drop(1) end
  
  # These compositions can extend ad infinitum:
  # caaar, caadr, cadar,...
  # caaaar, caaadr, ...
  # caaaaar, ..., cadaadr, ...
  # ...
  # 
  # The combination of 'a' and 'd' letter controls, in reverse order,
  # the combination in which car and cdr is applied in a single pipeline.
  # 
  # Pyper adds a few modifications and extensions to this idea:
  #
  # ******************************************************************
  #
  # 1. Twin-barrel piping: Instead of just one pipeline, in which the
  # operations are applied in sequence, Pyper has 2 parallel pipelines.
  #
  #
  # 2. Greek letters τ, π, χ as method delimiters: Instead of 'c' and 'r' of
  # car/cdr family, Pyper methods start and end with any of the characters
  # 'τ', 'π', 'χ' (small Greek tau, pi and chi). Choice of the character
  # conveys specific meaning, which is best explained by case enumeration:
  #
  # τ...τ means single-pipe input and output,
  # τ...π means single-pipe input, double-pipe output
  # τ...χ means single-pipe input, double-pipe output with a swap
  # π...τ means double-pipe input, single-pipe output
  # . . .
  # χ...χ means double-pipe input with a swap, and same for the output
  #
  # (Mnemonic for this is, that τ has one (vertical) pipe, π has two pipes,
  # and χ looks like two pipes crossed)
  # 
  # As for the meaning, single-pipe input means, that a single object (the
  # message receiver) is fed to the pipeline. Double-pipe input means, that
  # the receiver is assumed to respond to methods #size and #[], its size is
  # 2, and this being fulfilled, pipeline 0 and 1 are initialized
  # respectively with the first and second element of the receiver as per
  # method #[]. Double-pipe input with swap is the same, but the two
  # elements of the receiver are swapped: pipeline 1 receives the first,
  # pipeline 0 the second.
  # 
  # 3. Postfix order of commands: While traditional car/cdr family of
  # methods applies the letters in the prefix order (from right to left),
  # Pyper uses postfix order (left to right).
  #
  # Example: #cdar becomes τadτ ('da' reversed to 'ad')
  #          #cadaar becomes τaadaτ ('adaa' reversed to 'aada')
  #
  # 4. Extended set of commands: The set of command characters, which in the
  # traditional car/cdr method family consists only of two characters, 'a'
  # and 'd', is greatly extended.
  #
  # For example, apart from 'a', mening first, 'b' means second, and 'c'
  # means third:
  #
  # ["See", "you", "later", "alligator"].τaτ    #=>    "See"
  # ["See", "you", "later", "alligator"].τbτ    #=>    "you"
  # ["See", "you", "later", "alligator"].τcτ    #=>    "later"
  #
  # For another example, apart from 'd', meaning all except first, 'e' means
  # all except first two, and 'f' means all except first three:
  # ["See", "you", "later", "alligator"].τdτ = ["you", "later", "alligator"]
  # ["See", "you", "later", "alligator"].τeτ = ["later", "alligator"]
  # ["See", "you", "later", "alligator"].τfτ = ["alligator"]
  #
  # These command characters can be combined just like 'a' and 'd' letters
  # in the traditional car/cdr family - just beware of the Pyper's postfix
  # order:
  #
  # ["See", "you", "later", "alligator"].τddτ = ["later", "alligator"]
  # ["See", "you", "later", "alligator"].τdeτ = ["alligator"]
  # ["See", "you", "later", "alligator"].τdeaτ = "alligator"
  # ["See", "you", "later", "alligator"].τdeadτ = "lligator"
  # ["See", "you", "later", "alligator"].τdeafτ = "igator"
  # ["See", "you", "later", "alligator"].τdeafbτ = "g"
  #
  # Many more command characters are available.
  #
  # 5. Method arguments are possible: Unlike the traditional car/cdr family,
  # Pyper methods accept arguments. Regardless of the combination of the
  # command characters, any Pyper method can accept an arbitrary number of
  # arguments, which are [collected] into the 'args' variable, from which
  # the methods triggered by the command characters may take their arguments
  # as their arity requires.
  #
  # ******************************************************************
  #
  # So much for the main concepts. As for the character meanings, those are
  # defined as PostfixMachine methods of the same name (the name consists of
  # 1 or 2 characters). At the moment, it is necessary to read the
  # PostfixMachine code as their documentation.
  
  # Controlling the argument source
  # ********************************************************************
  # Pyper extends the car/cdr idea not just by adding more command
  # letters, but also by allowing the methods triggered by these command
  # letters to take arguments. Normally, 0 arity methods act only upon a
  # single object: the method receiver present in the current
  # pipeline. Higher arity methods, that require arguments, grab these
  # arguments by default from the argument field supplied to the Pyper
  # method (available as args local array variable). The argument source
  # can also be redefined to something else. This is done by pushing the
  # argument source prescription onto the write-time argument source stack
  # (@argsrc instance variable of the PostfixMachine method writer). After
  # this, the methods written by the command characters pop their argument
  # sources as needed from the argument source stack.
  #
  # As already said, the default argument source is the argument list
  # supplied to the Pyper method accessible at runtime as 'args' local
  # variable. In the course of writing a method, PostfixMachine maintains
  # the index (@arg_count PostfixMachine instance variable), pointing at
  # position in the 'args' variable, from which the next argument will be
  # taken. @arg_count is gradually incremented (at method write time) as
  # the arguments are distributed from args variable to the internal
  # methods in need of arguments. @arg_count does not apply at all at
  # runtime, so for methods inside blocks, that are looped over many times
  # at runtime, their arguments still come from the same position in the
  # args array. This can be changed by switching on the 'shift' grab
  # method: In this case, #shift method is called upon the argument source
  # object, which normally cuts off and returns the current first element
  # from a collection, which happens at runtime. (Examples needed.)
  #
  # Greek characters corresponding to the internal variable names of the
  # Pyper method are used to manipulate the argument source stack:

  # Reacts to the method symbols delimited with Pyper control characters (τ, π,
  # and χ), compiles them into appropriate methods, and calls them.
  # 
  def method_missing( symbol, *args, &block )
    str = symbol.to_s
    super if str.starts_with? 'to_' # quick exclude of "to_something" methods
    puts "received msg #{str}" if Pyper::DEBUG > 1
    case str
    when /^τ(.+)τ$/ then pyper_mm( symbol, $1, op: 1, ret: 1 )
    when /^π(.+)τ$/ then pyper_mm( symbol, $1, op: 2, ret: 1 )
    when /^χ(.+)τ$/ then pyper_mm( symbol, $1, op: -2, ret: 1 )
    when /^τ(.+)π$/ then pyper_mm( symbol, $1, op: 1, ret: 2 )
    when /^π(.+)π$/ then pyper_mm( symbol, $1, op: 2, ret: 2 )
    when /^χ(.+)π$/ then pyper_mm( symbol, $1, op: -2, ret: 2 )
    when /^τ(.+)χ$/ then pyper_mm( symbol, $1, op: 1, ret: -2 )
    when /^π(.+)χ$/ then pyper_mm( symbol, $1, op: 2, ret: -2 )
    when /^χ(.+)χ$/ then pyper_mm( symbol, $1, op: -2, ret: -2 )
    else super end
    send symbol, *args, &block # call it right away
  end

  # Respond-to method matching to +Pyper#method_missing+.
  # 
  def respond_to_missing?( symbol, include_private = false )
    str = symbol.to_s
    super if str.starts_with? 'to_'
    case str
    when /^τ(\w+)τ$/, /^π(\w+)τ$/, /^χ(\w+)τ$/,
         /^τ(\w+)π$/, /^π(\w+)π$/, /^χ(\w+)π$/,
         /^τ(\w+)χ$/, /^π(\w+)χ$/, /^χ(\w+)χ$/ then true
    else super end
  end

  private

  # Private subroutine for compiling a Pyper method and attaching it to the
  # current class.
  # 
  def pyper_mm symbol, command_string, **opts
    code = PostfixMachine.new( command_string ).compile( symbol, opts )
    code.gsub! /^alpha = alpha\n/, "alpha\n"    # workaround
    code.gsub! /^alpha\nalpha\n/, "alpha\n"     # workaround
    code.gsub! /^alpha\nalpha =/, "alpha ="     # workaround
    code.gsub! /^alpha = alpha =/, 'alpha ='    # workaround
    puts code if Pyper::DEBUG > 0
    self.class.module_eval( code )
  end
end # module Pyper

class Object
  def π
    tap do |o|
      begin
        o.singleton_class
      rescue TypeError
        o.class
      end.class_exec { include Pyper }
    end
  end
end

module Enumerable
  include Pyper
end

class Array
  include Pyper
end

class Hash
  include Pyper
end

class String
  include Pyper

  # Annoying little detail.
  # 
  alias starts_with? start_with?
  alias ends_with? end_with?
end
