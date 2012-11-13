#coding: utf-8

require "pyper/version"

# Piper is an extension of the Lispy car/cdr idea.
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
  
  def method_missing( mτ_sym, *args, &block )
    pyperλ = lambda { | opts |
      mτ_string = PostfixMachine.new( $1 ).write_mτ( mτ_sym, opts )
      mτ_string.gsub! /^alpha = alpha\n/, "alpha\n"    # workaround
      mτ_string.gsub! /^alpha\nalpha\n/, "alpha\n"     # workaround
      mτ_string.gsub! /^alpha\nalpha =/, "alpha ="     # workaround
      mτ_string.gsub! /^alpha = alpha =/, 'alpha ='    # workaround
      # puts mτ_string # DEBUG
      self.class.module_eval( mτ_string )
      send( mτ_sym, *args, &block )
    }
    # puts "received msg #{mτ_sym}" # DEBUG
    case mτ_sym.to_s
    when /^τ(.+)τ$/ then pyperλ.( op: 1, ret: 1 )
    when /^π(.+)τ$/ then pyperλ.( op: 2, ret: 1 )
    when /^χ(.+)τ$/ then pyperλ.( op: -2, ret: 1 )
    when /^τ(.+)π$/ then pyperλ.( op: 1, ret: 2 )
    when /^π(.+)π$/ then pyperλ.( op: 2, ret: 2 )
    when /^χ(.+)π$/ then pyperλ.( op: -2, ret: 2 )
    when /^τ(.+)χ$/ then pyperλ.( op: 1, ret: -2 )
    when /^π(.+)χ$/ then pyperλ.( op: 2, ret: -2 )
    when /^χ(.+)χ$/ then pyperλ.( op: -2, ret: -2 )
    else super end
  end
  
  def respond_to_missing?( mτ_sym, include_private = false )
    case mτ_sym.to_s
    when /^τ(\w+)τ$/, /^π(\w+)τ$/, /^χ(\w+)τ$/,
      /^τ(\w+)π$/, /^π(\w+)π$/, /^χ(\w+)π$/,
      /^τ(\w+)χ$/, /^π(\w+)χ$/, /^χ(\w+)χ$/ then true
    else super end
  end
  
  # PostfixMachine is an algorithmic writer of Pyper methods. Each Pyper
  # method has two pipelines: 'alpha' (no. 0) and 'beta' (no. 1). Variables
  # 'alpha' and 'beta' are local to the main scope of a Pyper method.
  #
  # When blocks are used inside a Pyper method, variable 'delta' local to
  # the block is used to hold the pipeline inside the block. For blocks with
  # arity 1, variable named 'epsilon' is used to hold the block argument.
  # For blocks with arity 2, variables named 'epsilon', resp. 'zeta' are
  # used to hold 1st, resp. 2nd block argument. Blocks with arity higher
  # than 2 are not allowed in Pyper methods. (However, Pyper methods may
  # receive external block of arbitrary construction.)
  #
  # Control characters are still under heavy development - presently, one
  # must read the code to learn about their exact meaning.
  #
  class PostfixMachine
    PREFIX_CHARACTERS =
      ['ℓ'] <<                     # math script ℓ (as in litre)
      '¡' <<                       # inverted exclamation mark
      '¿' <<                       # inverted question mark
      '‹' <<                       # single left pointing quotation mark
      '›' <<                       # single right pointing quotation mark
      '﹦' <<                       # small equals sign
      '﹕' <<                       # small colon
      '﹡'                          # small asterisk
    
    SUCC = { alpha: :beta, beta: :alpha, α: :β, β: :α } # successor table
    PRE = { alpha: :beta, beta: :alpha, α: :β, β: :α } # predecessor table

    # Template for the def line of the method being written:
    DEF_LINE = lambda { |ɴ| "def #{ɴ}( *args, &block )" }
    
    # The default source of arguments in Pyper methods is 'args' local
    # variable, where arguments supplied to the Pyper methods are
    # collected. However, this default argument source can be changed to
    # something else. For this purpose, at write time of a Pyper method,
    # stack is maintained, showing where the next argument will come from.
    # The following closure is basically the constructor of this stack,
    # which is implemented as a Hash with two keys :src and :grab,
    # describing respectively the argument source, and what to do with it to
    # obtain the required argument from it.
    #
    # Possible argument source objects:
    # :args (whole argument array),
    # :args_counted (args referenced using a write-time counter - default)
    # :alpha (primary pipeline)
    # :beta (secondary pipeline)
    # :delta (in-block pipeline)
    # :epsilon (block argument 0)
    # :zeta (block argument 1)
    # :psi (penultimate element in the args array; penultimate argument)
    # :omega (last element in the args array; last argument)
    # 
    # Argument grab methods:
    # :ref (by simple reference to the object specified as the arg. source)
    # :dup (by #dup of the object specified as the arg. sourc)
    # :shift (by calling runtime #shift on the obj. spec. as the arg. src.)
    #
    # So here goes the closure:
    ARG_SOURCES_AND_GRAB_METHODS = lambda {
      # We start from a ꜧ with 2 keys (:src & :grab) pointing to 2 ᴀs:
      ◉ = { src: [:args_counted], grab: [:ref] }
      ◉.define_singleton_method :src do self[:src] end
      ◉.define_singleton_method :grab do self[:grab] end
      ◉.define_singleton_method :src= do |arg| self[:src] = arg end
      ◉.define_singleton_method :grab= do |arg| self[:grab] = arg end
      # Now, onto this ◉, mτs are patched for setting argument sources.
      # In general, mτs ending in ! modify topmost source on the arg.
      # source stack, while mτs without ! push a new arg. source on the
      # stack. The exception is the #std! method, which resets the stack:
      ◉.define_singleton_method :std! do src = [:args_counted]; grab = [:ref] end
      # #define_singleton_method means #define_singleton_method
      ◉.define_singleton_method :args_counted do src.push :args_counted; grab.push :ref end
      ◉.define_singleton_method :args_counted! do src[-1] = :args_counted end
      ◉.define_singleton_method :args do src.push :args; grab.push :shift end
      ◉.define_singleton_method :args! do src[-1] = :args; grab[-1] = :shift end
      ◉.define_singleton_method :alpha do src.push :alpha; grab.push :ref end
      ◉.define_singleton_method :alpha! do src[-1] = :alpha end
      ◉.define_singleton_method :beta do src.push :beta; grab.push :ref end
      ◉.define_singleton_method :beta! do src[-1] = :beta end
      ◉.define_singleton_method :delta do src.push :delta; grab.push :ref end
      ◉.define_singleton_method :delta! do src[-1] = :delta end
      ◉.define_singleton_method :epsilon do src.push :epsilon; grab.push :ref end
      ◉.define_singleton_method :epsilon! do src[-1] = :epsilon end
      ◉.define_singleton_method :zeta do src.push :zeta; grab.push :ref end
      ◉.define_singleton_method :zeta! do src[-1] = :zeta end
      ◉.define_singleton_method :psi do src.push :psi; grab.push :ref end
      ◉.define_singleton_method :psi! do src[-1] = :psi end
      ◉.define_singleton_method :omega do src.push :omega; grab.push :ref end
      ◉.define_singleton_method :omega! do src[-1] = :omega end
      # methods #var/#var! take a parameter and push/change the stack top
      ◉.define_singleton_method :var do |variable| src.push variable; grab.push :ref end
      ◉.define_singleton_method :var! do |variable| src[-1] = variable end
      # methods #shift! and #ref! change only the grab method:
      ◉.define_singleton_method :shift! do grab[-1] = :shift end
      ◉.define_singleton_method :ref! do grab[-1] = :ref end
      ◉.define_singleton_method :dup! do grab[-1] = :dup end
      return ◉
    }
    
    # PostfixMachine initialization
    def initialize command_ς
      @cmds = parse_command_string( command_ς )
    end
    
    # Command ς -> command ᴀ
    def parse_command_string( arg )
      # If supplied arg is an ᴀ, assume that it already is a command
      # sequence, and thus, no work at all is needed:
      return arg if arg.kind_of? Array
      # Otherwise, assume arg is a ς and split it using #each_char
      arg.to_s.each_char.with_object [] do |char, memo|
        # Handle prefix characters:
        ( PREFIX_CHARACTERS.include?(memo[-1]) ? memo[-1] : memo ) << char
      end
    end
    
    # Algorithmically writes a Ruby mτ, whose name is given as 1st arg.,
    # and the options ꜧ expects 2 keys (:op and :ret) as follows:
    # 
    # op: when 1 (single pipe), makes no assumption about the receiver
    #     When 2 (twin pipe), assumes the receiver is a size 2 ᴀ,
    #            consisting of pipes a, b
    #     When -2 (twin pipe with a swap), assumes the same as above and
    #             swaps the pipes immediately (a, b = b, a)
    #             
    # ret: when 1 (single return value), returns current pipe only
    #      when 2 (return both pipes), returns size 2 ᴀ, consisting
    #             of pipes a, b
    #      when -2 (return both pipes with a swap), returns size 2 ᴀ
    #              containing the pipes' results in reverse order [b, a]
    #              
    def write_mτ( ɴ, opts={} )
      @opts = { op: 1, ret: 1 }.merge( opts )
      @opts.define_singleton_method :op do self[:op] end
      @opts.define_singleton_method :ret do self[:ret] end
      
      # Initialize argument sourcing
      @argsrc = ARG_SOURCES_AND_GRAB_METHODS.call
      
      initialize_writer_state
      write_mτ_head_skeleton( ɴ )
      write_initial_pipeline
      write_mτ_tail_skeleton
      
      # Now that we have the skeleton, let's write the meat.
      write_mτ_meat
      
      # puts "head is #@head\npipe is #@pipe\ntail is #@tail" # DEBUG
      
      # Finally, close any blocks and return
      autoclose_open_blocks_and_return
    end
    
    # private
    
    # Initialize method writing flags / state keepers
    def initialize_writer_state
      # set current pipeline to :alpha (pipeline 0)
      @r = :alpha

      # set current pipe stack to [@r]
      @rr = [@r]
      # (Pipeline stack is needed due to tha fact, that blocks are allowed
      # inside a Pyper method. At method write time, every time a block is
      # open, block pipeline symbol is pushed onto this stack.)

      # where are we? flag (whether in :main or :block) set to :main
      @w = :main

      # argument counter (for args dispensing to the individual methods)
      @arg_count = 0

      # signal to pass the supplied block to the next method
      @take_block = false
      
      # arity flag for next block to be written, default is 1
      @block_arity = 1
    end
    
    # Write the skeleton of the method header:
    def write_mτ_head_skeleton( ɴ )
      @head = [ [ DEF_LINE.( ɴ ) ] ] # write first line "def ɴ..."
      write "\n"
      # write validation line (written only when @opts[:op] == 2)
      write "raise 'Receiver must be a size 2 array when double-piping!'" +
        "unless self.kind_of?( Array ) and self.size == 2\n" if
        @opts.op == 2
      # 'main_opener' (global)
      write @main_opener = ""
      # 'opener' (local to block)
      write opener = ""
      @opener = [ opener ]
    end
    
    # Initialize the pipeline (@pipe)
    def write_initial_pipeline
      @pipe = case @opts.op
              when 1 then [ "self" ]   # use receiver (default)
              when 2 then              # use alpha, beta = self[0], self[1]
                @alpha_touched = @beta_touched = true
                write "\n( alpha, beta = self[0], self[1]; alpha)\n"
                [ "alpha" ]            # pipe 0 aka. primary pipe
              when -2 then             # use alpha, beta = self[1], self[0]
                @alpha_touched = @beta_touched = true
                write "\n( alpha, beta = self[1], self[0]; alpha)\n"
                [ "alpha" ]            # pipe 0 aka. primary pipe
              end # self compliance tested in the written method itself
      write "\n"; write @pipe[-1]      # make @pipe part of @head
    end
    
    # Write the skeleton of the tail part of the method, consisting
    # of the finisher line, returner line, and end statement itself.
    def write_mτ_tail_skeleton
      finisher = String.new              # 'finisher' (local to block)
      @finisher = [ finisher ]
      @returner = case @opts.ret         # 'returner' (global finisher)
                  when 1 then ""
                  when 2 then alpha_touch; beta_touch; "return alpha, beta"
                  when -2 then alpha_touch; beta_touch; "return beta, alpha"
                  else raise "wrong @opts[:fin] value: #{@opts.fin}" end
      @tail = [ [ finisher, "\n", @returner, "\n", "end" ] ] # end line
    end
    
    # This consists of taking the atomic commands from @cmds array one by
    # one and calling the command method to write a small piece of the
    # program implied by the command.
    def write_mτ_meat
      while not @cmds.empty?
        # First, slice off the next command from @cmds array
        cmd = @cmds.shift
        
        # puts "doing command #{cmd}, @r is #@r, @head is #@head" # DEBUG
        # puts "doing command #{cmd}, @argsrc is #@argsrc" # DEBUG
        
        # Take the block (if not taken) if this is the last command
        
        @take_block = true unless @take_block == :taken if @cmds.size <= 0
        # Now send the command to self. Commands are implemented as
        # methods of Pyper::PostfixMachine with one or two-character
        # names. These methods then take care of writing the program
        # pieces implied by these commands. Side effects of this is, that
        # one- and two-character local variables should be avoided inside
        # whole PostfixMachine class.
        # puts "about to self.send( #@w, #{cmd} )" # DEBUG
        self.send @w, cmd
        pipe_2_variable if @cmds.size <= 0
      end
    end
    
    # After we run out of atomic commands, it's time to finalize the
    # program by closing any blocks still left open. Metod #close_block
    # called by this method actually produces the program string out of
    # each block it closes, so this method actually returns the program
    # string of whole newly written Pyper method.
    def autoclose_open_blocks_and_return
      loop { ( rslt = close_block; chain rslt; pipe_2_variable) if @head.size > 1
        return close_block }
    end
    
    # Called to close a block, including the main def
    def close_block
      unless @rr.empty? then @r = @rr.pop end # back with the register
      @pipe.pop; @opener.pop; @finisher.pop   # pop the writing stack
      ( @head.pop + @tail.pop ).join          # join head and tail
    end
    
    # Writer of argument grab strings.
    def grab_arg
      raise ArgumentError unless @argsrc.src.size == @argsrc.grab.size
      grab = case @argsrc.grab.last
             when :shift then ".shift"
             when :ref then ""
             when :dup then ".dup"
             else raise "unknown arg. grab method: #{@argsrc.grab.last}" end
      str = case @argsrc.src.last
            when :args_counted
              x = (@arg_count += 1) - 1; "args[#{x}]" + grab
            when :args then        # now this is a bit difficult, cause
              case @argsrc.grab.last   # it's necessary to discard the used
              when :shift then     # args (shift #@arg_count):
                if @arg_count == 0 then "args.shift"
                else "(args.shift(#@arg_count); args.shift)" end
              when :ref then "args"
              else raise "unknown arg. grab method: #{@argsrc.grab.last}" end
            when :alpha then alpha_touch; 'alpha' + grab
            when :beta then beta_touch; 'beta' + grab
            when :delta, :epsilon, :zeta then @argsrc.src.last.to_s + grab
            when :psi then "args[-2]" + grab
            when :omega then "args[-1]" + grab
            else raise "unknown argument source: #{@argsrc.src.last}" end
      unless @argsrc.src.size <= 1 then @argsrc.src.pop; @argsrc.grab.pop end
      return str
    end
    
    # Execution methods (depending on @w at the moment)
    def main( cmd ); self.send( cmd ) end
    def block( cmd ); self.send( cmd ) end
    
    # ********************************************************************
    # Script writing subroutines
    # ********************************************************************
    
    # Active register reader
    def _r_; @r end
    # Append string to head
    def write( x ); Array( x ).each {|e| @head[-1] << e } end
    # Chain (nullary) method string to the end of the pipe
    def chain( s ); @pipe[-1] << ".#{s}" end
    # Suck the pipe into the "memory" (active register)
    def pipe_2_variable; @pipe[-1].prepend "#@r = "; eval "#{@r}_touched = true" end
    # Start a new pipe, on a new line. Without arguments, @r is used
    def start( s = "#@r" ); write "\n"; @pipe[-1] = s; write @pipe.last end
    # Set the pipe to a value, discarding current contents
    def set( s ); @pipe[-1].clear << s end
    # Store in active register, and continue in a new pipeline:
    def belay; pipe_2_variable; start end
    # pipe_2_variable, execute something else, and go back to @r
    def exe( s ); pipe_2_variable; start s; start end
    # parethesize current pipe
    def paren; @pipe[-1].prepend("( ") << " )" end
    # Write binary operator
    def bin_op( s, x = grab_arg ); @pipe[-1] << " #{s} " << x end
    # Write unary operator
    def unary_op( s ); paren; @pipe[-1].prepend s end
    # Returns nothing or optional block, if flagged to do so
    def maybe_block; case @take_block
                     when true then @take_block = :taken; '&block'
                     when nil, false, :taken then nil
                     else raise "unexpected @take_block value" end
    end
    # Chain unary method
    def nullary_m( s ); chain "#{s}(#{maybe_block})" end
    def unary_m( s, x = grab_arg )
      chain "#{s}( #{[x, maybe_block].compact.join(", ")} )" end
    # Chain binary method
    def binary_m( s, x = grab_arg, y = grab_arg )
      chain "#{s}( #{[x, y, maybe_block].compact.join(", ")} )" end
    # Initiates writing a block method.
    def nullary_m_with_block( str )
      # puts "in nullary_m_with_block, str = #{str}" # DEBUG
      if @take_block == true then
        nullary_m( str )
      else            # code a block
        @w = :block                  # change writing method
        belay                        # a must before block opening
        # push a new pipe, head and tail to the writing stack:
        @rr.empty? ? ( @rr = [@r] ) : ( @rr.push @r ) # store the register
        @r = :delta # a block runs in its own unswitchable register delta
        @pipe << String.new          # push pipe
        # puts "@pipe is << #@pipe >>" # DEBUG
        @head << case @block_arity   # push head
                 when 0 then [ "#{str} { " ]
                 when 1 then set "delta"; [ "#{str} { |epsilon|" ]
                 when 2 then @argsrc.zeta; @argsrc.ref!
                   set "delta"; [ "#{str} { |epsilon, zeta|" ]
                 when -2 then @argsrc.epsilon; @argsrc.ref!
                   set "delta"; [ "#{str} { |epsilon, zeta|" ]
                 else raise "Unknown @block_arity: #@block_arity"
                 end
        write "\n"
        opener = case @block_arity; when 0 then "";
                 when 1, 2 then "delta = epsilon"
                 when -2 then "delta = zeta" end
        @opener << opener              # push opener
        @block_arity = 1     # after use, set block arity flag back to default
        # puts "@pipe is << #@pipe >>" # DEBUG
        write opener; write "\n"; write @pipe.last
        finisher = String.new
        @finisher << finisher                 # push finisher
        @tail << [ "\n" ]                     # push tail
        @tail.last << finisher << "\n" << "}" # done
      end
    end
    
    # Next block will be written as binary:
    def block_2ary; @block_arity = 2 end

    # Next block will be writen as binary with swapped block arguments
    # (delta = zeta; @argsrc.epsilon):
    def block_2ary_swapped; @block_arity = -2 end
    
    # register 0 (alpha) was required for computation
    def alpha_touch; belay unless @alpha_touched or @beta_touched end
    
    # register 1 (beta) was required for the computation
    def beta_autoinit
      case @opts.op
      when 1 then s = "beta = self.dup rescue self"
        ( @main_opener.clear << s; @beta_touched = true ) unless @beta_touched
      when 2 then @main_opener.clear << "beta = self[1]" unless @beta_touched
      when -2 then @main_opener.clear << "beta = self[0]" unless @beta_touched
      else raise "wrong @opts[:op] value: #{@opts.op}" end
    end
    alias :beta_touch :beta_autoinit

    # touch and return successor of a register, or @r by default
    def rSUCC reg=@r; send "#{SUCC[reg]}_touch"; SUCC[reg] end

    # touch and return predecessor of a register, or @r by default
    def rPRE reg=@r; send "#{PRE[reg]}_touch"; PRE[reg] end
    
    # Traditional letters with extension to the first 3 elements
    # ********************************************************************
    # In the strict sense, there are only 2 traditional letters in these
    # kinds of functions: 'a' and 'd' of car/cdr Lisp fame.
    
    # In Pyper, 'car' becomes 'τaτ', and applies to strings, too:
    def a; pipe_2_variable; start "#@r =\n" +
        "if #@r.respond_to?( :first ) then #@r.first\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0]\n" +
        "else raise 'impossible to extract first element' end"
      start
    end

    # Extension of this idea: 'b' is 2nd, 'c' is 3rd:
    def b; pipe_2_variable; start "#@r =\n" +
        "if #@r.respond_to?( :take ) then #@r.take(2)[1]\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[1]\n" +
        "else raise 'unable to extract second collection element' end"
      start
    end    

    def c; pipe_2_variable; start "#@r =\n" +
        "if #@r.respond_to?( :take ) then #@r.take(3)[2]\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[2]\n" +
        "else raise 'unable to extract third collection element' end"
      start
    end    
    
    # In Pyper 'cdr' becomes 'τdτ':
    def d; pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop(1) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop(1)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[1..-1]\n" +
        "else raise 'unable to #drop(1) or #[1..-1]' end"
      start
    end
    
    # 'e', 'f' mean all but first 2, resp. 3 elements:
    def e; pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop(2) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop(2)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[2..-1]\n" +
        "else raise 'unable to #drop(2) or #[2..-1]' end"
      start
    end
    def f; pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop(3) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop(3)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[3..-1]\n" +
        "else raise 'unable to #drop(3) or #[3..-1]' end"
      start
    end
    
    # Extending these ideas also to the collection last 3 elements
    # ********************************************************************
    
    # 'z' - last element
    def z; pipe_2_variable; start "#@r =\n" +
        "if #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 1 ).first\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-1]\n" +
        "else raise 'unable to extract last element' end"
      start
    end

    # 'y' - penultimate element
    def y; pipe_2_variable; start "#@r =\n" +
        "if #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 2 ).first\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-2]\n" +
        "else raise 'unable to extract second-from-the-end element' end"
      start
    end

    # 'x' - 3rd from the end
    def x; pipe_2_variable; start "#@r =\n" +
        "if #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 3 ).first\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-3]\n" +
        "else raise 'unable to extract third-from-the-end element' end"
      start
    end

    # 'w' - all except last
    def w; pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.take( #@r.size - 1 ) ]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take( #@r.size - 1 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0...-1]\n" +
        "else raise 'unable to #drop(1) or #[1...-1]' end"
      start
    end

    # 'v' - all except last 2
    def v; pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.take( #@r.size - 2 ) ]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take( #@r.size - 2 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0...-2]\n" +
        "else raise 'unable to #drop(1) or #[1...-2]' end"
      start
    end

    # 'u' - all except last 3
    def u; pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.take( #@r.size - 3 ) ]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take( #@r.size - 3 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0...-3]\n" +
        "else raise 'unable to #drop(1) or #[1...-3]' end"
      start
    end

    # Extending these ideas to access *lists* of first/last few elements
    # ********************************************************************
    # Now we still miss the lists of first n and last n elements. Digits
    # 0..4 will be used to refer to the lists of first 1, first 2, ...
    # first 5 elements. Digits 9..5 will be used to refer to the lists of
    # last 1, last 2, ... last 5 elements of the collection:

    # '0' - [1st]
    self.send :define_method, :'0' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[@r.take(1)]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take(1)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0..0]\n" +
        "else raise 'unable to #take(1) or #[0..0]' end"
      start
    end

    # '1' - [1st, 2nd]
    self.send :define_method, :'1' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[@r.take(2)]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take(2)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0..1]\n" +
        "else raise 'unable to #take(2) or #[0..1]' end"
      start
    end

    # '2' - [1st, 2nd, 3rd]
    self.send :define_method, :'2' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[@r.take(3)]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take(3)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0..2]\n" +
        "else raise 'unable to #take(3) or #[0..2]' end"
      start
    end

    # '3' - [1st, 2nd, 3rd, 4th]
    self.send :define_method, :'3' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[@r.take(4)]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take(4)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0..3]\n" +
        "else raise 'unable to #take(4) or #[0..3]' end"
      start
    end

    # '4' - [1st, 2nd, 3rd, 4th, 5th]
    self.send :define_method, :'4' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[@r.take(5)]\n" +
        "elsif #@r.respond_to?( :take ) then #@r.take(5)\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[0..4]\n" +
        "else raise 'unable to #take(5) or #[0..4]' end"
      start
    end

    # '5' - [-5th, -4th, -3rd, -2nd, -1st] (ie. last 5 elements)
    self.send :define_method, :'5' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 5 ) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 5 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-5..-1]\n" +
        "else raise 'unable to take last 5 or call #[-5..-1]' end"
      start
    end

    # '6' - [-4th, -3rd, -2nd, -1st] (ie. last 4 elements)
    self.send :define_method, :'6' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 4 ) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 4 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-4..-1]\n" +
        "else raise 'unable to take last 4 or call #[-4..-1]' end"
      start
    end

    # '7' - [-3rd, -2nd, -1st] (ie. last 3 elements)
    self.send :define_method, :'7' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 3 ) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 3 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-3..-1]\n" +
        "else raise 'unable to take last 3 or call #[-3..-1]' end"
      start
    end
    
    # '8' - [-3rd, -2nd] (ie. last 2 elements)
    self.send :define_method, :'8' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 2 ) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 2 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-2..-1]\n" +
        "else raise 'unable to take last 2 or call #[-2..-1]' end"
      start
    end

    # '9' - [-1st] (ie. an array with only the last collection element)
    self.send :define_method, :'9' do
      pipe_2_variable; start "#@r =\n" +
        "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 1 ) ]\n" +
        "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 1 )\n" +
        "elsif #@r.respond_to?( :[] ) then #@r[-1..-1]\n" +
        "else raise 'unable to take last 1 or call #[-1..-1]' end"
      start
    end

    # (Remark: In the method definitions above, the message sent to the
    # PostfixMachine instance consist of a single digit. Due to the
    # syntactic rules, it is not possible to define these methods with 'def'
    # statement. Also, these methods cann be invoked only by explicit
    # message passing. This limitation is fine for this particular usecase.)

    # Controlling block writing
    # ********************************************************************
    # Certain command characters cause writing a block opening. This block
    # has certain arity (1 or 2), and is closed either automatically closed
    # at the end of the command character sequence, or it can be closed
    # explicitly earlier.

    # Next block arity 2 selection
    def ²; block_2ary end

    # Superscript i. Next block will have arity 2 and will be written with
    # inverse parameter order.
    def ⁱ; block_2ary_swapped end

    # Explicit block closing. 
    def _
      case @w           # close block when in :block
      when :block then
        chain( close_block )
        @w = :main if @rr.size == 1 unless @rr.empty?
      else raise "'_' (close block) used when not in block" end
    end
    
    # Controlling the pipes
    # ********************************************************************
    def χ; case @w           # swap registers when in :main
           when :block then raise "'χ' (swap pipes) used when in block"
           else exe "#@r, #{rSUCC} = #{rSUCC}, #@r" end
    end
    
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
    
    # α pushes the primary pipeline (0) on the @argsrc stack:
    def α; @argsrc.alpha end
    # (Remark: Current pipe name is at the bottom of the @rr pipe stack)
    
    # β pushes the secondary pipeline (1) on the @argsrc stack:
    def β; @argsrc.beta end
    # (Remark: SUCC hash tells us what the other pipe is, based on the
    # current pipe name, seen on the *bottom* of the pipe stack @rr)
    
    # γ refers to the successor pipe (SUCC[@rr[0]]), but as there are only
    # two pipes, it is always the other pipe.
    def γ; @argsrc.var rSUCC( @rr[0] ) end
    
    # δ pushes the in-block pipeline delta on the @argsrc stack:
    def δ; @argsrc.delta end
    
    # ε, ζ push block arguments epsilon, resp. zeta on the @argsrc stack:
    def ε; @argsrc.epsilon end
    def ζ; @argsrc.zeta end
    
    # ψ and ω respectively refer to the penultimate and last args element:
    def ψ; @argsrc.psi end
    def ω; @argsrc.omega end
    
    # Lambda pushes onto the argument stack the default argument source, which
    # is the argument list indexed with write-time @arg_count index:
    def λ; @argsrc.args_counted end
    
    # Capital omega pushes onto the argument stack whole 'args' variable
    # (whole argument list), with 'shift' mode turned on by default:
    def Ω; @argsrc.args end
    
    # When inverted exclamation mark '¡' is used a prefix to the source
    # selector, then rather then being pushed on the @argsrc stack, the new
    # argument source replaces the topmost element of the stak. When the
    # stack size is 1, this has the additional effect of setting the given
    # argument source as default, until another such change happens, or
    # stack reset is invoked.
    def ¡α; @argsrc.alpha! end
    def ¡β; @argsrc.beta! end
    # def ¡γ; @argsrc.var! PRE[@rr[0]]
    def ¡δ; @argsrc.delta! end
    def ¡ε; @argsrc.epsilon! end
    def ¡ζ; @argsrc.zeta! end
    def ¡ψ; @argsrc.psi! end
    def ¡ω; @argsrc.omega! end
    def ¡λ; @argsrc.args_counted! end
    def ¡Ω; @argsrc.args! end
    
    # Small pi sets the 'dup' grab mode for the top @argsrc element:
    def π; @argsrc.shift! end

    # Small sigma sets the 'shift' grab mode for the top @argsrc element:
    def σ; @argsrc.shift! end
    
    # Small pi prefixed with inverted exclamation mark sets the 'ref'
    # (default) grab mode for the top@argsrc element (naturally, turning off
    # 'shift' or 'dup' mode).
    def ¡π; @argsrc.ref! end
    # Same for small sigma prefixed with inverted exclamation mark:
    alias :¡σ :¡π
    
    # Iota decrements the @arg_count index. If iota is used once, it causes
    # that same argument is used twice. If iota is used repeatedly, pointer
    # goes further back in the arg. ᴀ.
    def ι; @arg_count -= 1 end

    # Rho prefixed with inverted exclamation mark resets the @argsrc stack
    # (to size 1, source: args_counted):
    def ¡ρ; @am.std! end

    # Remaining latin letters
    # ********************************************************************
    def g; @am.r rSUCC( @rr[0] ) end # arg. source: register (other)
    def h; set "args" end         # set pipe <- whole args array
    # i:
    def j; chain "join" end   # nullary join
    # k:
    # l:
    def m; nullary_m_with_block "map" end # All-important #map method
    # n:
    # o: prefix character
    # p: ? recursive piper method, begin
    # q: ? recursive piper method, end
    # r:
    # s: prefix character
    # t: prefix character

    # Latin capital letters
    # ********************************************************************
    def A; pipe_2_variable; start "Array(#@r)" end # Array( pipe )
    def B; @take_block = true unless @take_block == :taken end # eat block
    def C; paren end # explicit parenthesize
    def D; exe "#@r = #@r.dup" end # self.dup
    def E; exe "#{rSUCC} = #@r.dup" end # -> g
    # L
    def H; pipe_2_variable; start "Hash[#@r.zip(#{rSUCC})]" end
    def J; unary_m "join" end        # binary join
    # L:
    def M # Map zipped this and other register using binary block
      block_2ary
      pipe_2_variable
      start "#@r.zip(#{rSUCC})"
      nullary_m_with_block "map"
    end
    # M: occupied by map with binary block
    
    # N:
    # O: prefix character (ready to append literal)
    # P: recursive piper method, begin
    # Q: recursive piper method, end
    def R # Reverse zip: Zip other and this register
      pipe_2_variable
      start "#{rSUCC}.zip(#@a)"
    end
    # S:
    # T: prefix character
    def U; end                     # unsh/prep self 2 reg (other changed)
    def V; end                     # <</app self 2 reg (other changed)
    def W # Map zipped other and this register using binary block
      block_2ary                     # Mnemonic: W is inverted M
      pipe_2_variable
      start "#{rSUCC}.zip(#@r)"
      nullary_m_with_block "map"
    end

    # W: occupied by map with reverse order binary block
    # X:
    # Y:
    def Z # Zip this and other register
      pipe_2_variable
      start "#@r.zip(#{rSUCC})"
    end

    # Remaining Greek letters
    # ********************************************************************
    def ς; nullary_m "to_s" end

    # Small caps
    # ********************************************************************
    def ᴇ; bin_op "==" end # equal
    def ɪ; bin_op "||" end # memo: v is log. or
    def ᴊ; unary_m "join" end
    def ᴍ
      exe "#@r, #{rSUCC} = #{rSUCC}, #@r"
      unary_m "join"
      exe "#@r, #{rSUCC} = #{rSUCC}, #@r"
    end
    def ᴘ # make a pair
      pipe_2_variable
      arg = grab_arg
      start "[#@r, #{arg}]"
    end
    
    # Ternary operator
    # ********************************************************************
    # Guards in Pyper methods are provided by ( * ? * : * ) operator, using
    # the following command characters:
    
    # Question mark literal:
    def ﹖; @pipe[-1] << " ? " end
    # Colon literal: 
    def ﹕; @pipe[-1] << " : " end
    # As binary method:
    def ⁇; paren; @pipe[-1] << " ? ( #{grab_arg} ) : ( #{grab_arg} )" end
    # Left part up to colon (included) as unary method:
    def ⁈; @pipe[-1] << " ? ( #{grab_arg} ) : " end
    # Right part from colon (included) on as unary method:
    def ⁉; @pipe[-1] << " : ( #{grab_arg} )" end # ternary op. r. part

    # Other special character methods
    # ********************************************************************
    
    def ß; nullary_m "to_sym" end

    # Adaptive prepend:
    def →
      pipe_2_variable; arg = grab_arg; start "#@r =\n" + # arg 2 self
        "if #@r.respond_to?( :unshift ) then #@r.unshift(#{arg})\n" +
        "elsif #@r.respond_to?( :prepend ) then #@r.prepend(#{arg})\n" +
        "elsif #@r.respond_to?( :merge ) and #@r.is_a?( Array ) " +
        "&& #@r.size == 2\nHash[*#@r].merge(#{arg})\n" +
        "elsif #@r.respond_to? :merge then #@r.merge(#{arg})\n" +
        "else raise 'impossible to unshift/prepend' end"
      start
    end
    
    # Adaptive append:
    def ←
      pipe_2_variable
      arg = grab_arg
      start "#@r =\n" +   # arg 2 self
        "if #@r.respond_to?( :<< ) then #@r << #{arg}\n" +
        "elsif #@r.respond_to?( :merge ) and #@r.is_a?(Array) " +
        "&& #@r.size == 2\n#{arg}.merge(Hash[*#@r])\n" +
        "elsif #@r.respond_to?( :merge ) then #{arg}.merge(#@r)\n" +
        "else raise 'impossible to <</append' end"
      start
    end
    #               unsh. r to self,        << r to self
    # And eight more with Array construct [a, b]
    # def w; @am.args! end      # arg. source = whole args array (shift! on)
    # def x; pipe_2_variable; start( "#{rSUCC}.zip(#@r)" ) # zip other w. this
    
    def «; set grab_arg end           # grab argument into the current pipe
    def »; exe "args.unshift #@r" end # args.unshift from current pipe
    def ¡«                            # grab argument into the other pipe
      exe "#@r, #{rSUCC} = #{rSUCC}, #@r"
      set grab_arg
      exe "#@r, #{rSUCC} = #{rSUCC}, #@r"
    end
    def ¡»; exe "args.unshift #{rSUCC}" end # args.unshift from the other pipe
    
    def ¿i; unary_m "include?" end
    def ●; nullary_m "compact" end # ji3 - compact

    # Unary operators
    # ********************************************************************
    def ‹₊; unary_op "+" end       # subscript +, +@ method
    def ‹₋; unary_op "-" end       # subscript -, -@ method
    def ‹n; unary_op "not" end     # double exclamation mark, not operator
    def ‹﹗; unary_op "!" end       # small exclamation mark, !@ method
    
    def ₊; bin_op "+" end            # binary + as +() unary method
    def ₋; bin_op "-" end            # binary - as -() unary method
    def ★; bin_op "*" end            # binary * as *() unary method
    def ÷; bin_op "/" end            # binary / as /() unary method
    def ﹡﹡; bin_op "**" end           # binary ** as **() unary method
    def ﹪; bin_op "%" end            # binary % as %() unary method
    
    def ﹤; bin_op "<" end
    def ﹥; bin_op ">" end
    def ≤; bin_op "<=" end
    def ≥; bin_op ">=" end
      
    def ﹫; @pipe[-1] << "[#{grab_arg}]" end # []
    def ﹦﹫; @pipe[-1] << "[#{grab_arg}] = #{grab_arg}" end # []=
    def ﹠; bin_op "&&" end # memo: x is log. mult.
    def ››; bin_op ">>" end # mnemonic: precedes <<
    def ‹‹; bin_op '<<' end # mnemonic: z is last

    # Misc
    # ********************************************************************
    
    # def ru; end                    # unsh/prep reg 2 self (this changed)
    # def rv; end                    # <</app reg 2 self (this changed)
    # def rU; end                    # unsh/prep reg 2 self (other changed)
    # def rV; end                    # <</app reg 2 self (other changed)
    
    
    
    # def su; end                    # unsh/prep self 2 arg
    # def sv; end                    # <</app self 2 arg
    
    # def sy; nullary_m "to_sym" end
    
    # # sA: ? prependmap other, this, switch to other
    # # sB: ? appendmap other, this, switch to other
    
    # def sU; end                    # 
    # def sV; end
    
    def ›i; nullary_m "to_i" end
    def ›A; pipe_2_variable; start "[#@r]" end # make a singleton array

    
    # Appending literals
    
    def ﹕n; @pipe[-1] << "nil" end # nil literal
    def ﹕ς; @pipe[-1] << '' end    # empty string literal
    def ﹕ᴀ; @pipe[-1] << '[]' end  # empty array literal
    def ﹕ʜ; @pipe[-1] << '{}' end  # empty hash literal
    
    def ﹕₊; @pipe[-1] << ' + ' end # literal + waiting for another literal
    def ﹕₋; @pipe[-1] << ' - ' end # literal - waiting for another literal
    def ﹕★; @pipe[-1] << ' * ' end # literal * waiting for another literal
    def ﹕÷; @pipe[-1] << ' / ' end # literal / waiting for another literal
    def ﹕﹪; @pipe[-1] << ' % ' end # literal % waiting for another literal
    def ﹦﹦; @pipe[-1] << ' == ' end # literal == waiting for another literal
    def ﹕﹤; @pipe[-1] << ' < ' end  # literal < waiting for another literal
    def ﹕«; @pipe[-1] << ' << ' end  # literal << waiting for another literal
    def ﹕»; @pipe[-1] << ' >> ' end  # literal >> waiting for another literal

    # Digit literals
    def ₀; @pipe[-1] << "0" end
    def ₁; @pipe[-1] << "1" end
    def ₂; @pipe[-1] << "2" end
    def ₃; @pipe[-1] << "3" end
    def ₄; @pipe[-1] << "4" end
    def ₅; @pipe[-1] << "5" end
    def ₆; @pipe[-1] << "6" end
    def ₇; @pipe[-1] << "7" end
    def ₈; @pipe[-1] << "8" end
    def ₉; @pipe[-1] << "9" end
    
    # Clear the current pipe (set to empty string):
    def ∅; set "" end
    alias :⊘ :∅                      # similarly looking circled slash
    alias :ø :∅                      # similarly looking Danish ø
  end # class PostfixMachine
end # module Pyper
