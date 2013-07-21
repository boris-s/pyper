#coding: utf-8

require_relative 'postfix_machine/argument_source'
require_relative 'control_characters'

# PostfixMachine is a simple compiler of Pyper method symbols. Each written
# method has two pipelines: 'alpha' (no. 0) and 'beta' (no. 1). Variables
# 'alpha' and 'beta' are local to the main scope of a Pyper method.
#
# When blocks are used inside a Pyper method, variable 'delta' local to the
# block is used to hold the pipeline inside the block. For blocks with arity 1,
# variable named 'epsilon' is used to hold the block argument. For blocks with
# arity 2, variables named 'epsilon', resp. 'zeta' are used to hold 1st, resp.
# 2nd block argument. Blocks with arity higher than 2 are not allowed in Pyper
# methods. (However, Pyper methods may receive external block of arbitrary
# construction.)
#
class Pyper::PostfixMachine
  include Pyper::ControlCharacters

  SUCC = { alpha: :beta, beta: :alpha, α: :β, β: :α } # successor table
  PRE = { alpha: :beta, beta: :alpha, α: :β, β: :α } # predecessor table

  # Template for the def line of the method being written:
  DEF_LINE = -> name { "def #{name}( *args, &block )" }

  # PostfixMachine init. Requires the command string as an argument -- yes,
  # for each command string, a new PostfixMachine is instantiated.
  # 
  def initialize command_string
    @cmds = parse_command_string( command_string.to_s )
  end

  # Algorithmically writes a Ruby method, whose name is given in the first
  # argument. The options hash expects 2 named arguments -- +:op+ and +:ret+:
  # 
  # op: when 1 (single pipe), makes no assumption about the receiver
  #     When 2 (twin pipe), assumes the receiver is a size 2 array,
  #            consisting of pipes alpha, beta
  #     When -2 (twin pipe with a swap), assumes the same as above and
  #             swaps the pipes immediately (alpha, beta = beta, alpha)
  #             
  # ret: when 1 (single return value), returns the current pipe only
  #      when 2 (return both pipes), returns size 2 array, consisting
  #             of pipes a, b
  #      when -2 (return both pipes with a swap), returns size 2 array
  #              containing the pipes' results in reverse order [b, a]
  #              
  def compile( method_name, op: 1, ret: 1 )
    @opts = { op: op, ret: ret }.tap do |oo|
      oo.define_singleton_method :op do self[:op] end
      oo.define_singleton_method :ret do self[:ret] end
    end

    # Set up compile-time argument sourcing.
    @argsrc = ArgumentSource.new

    # Write the method skeleton.
    initialize_writer_state
    write_method_head_skeleton( method_name )
    write_initial_pipeline
    write_method_tail_skeleton

    # Now that we have the skeleton, let's write the meat.
    write_method_meat

    puts "head is #@head\npipe is #@pipe\ntail is #@tail" if Pyper::DEBUG > 1

    # Finally, close any blocks and return
    autoclose_open_blocks_and_return
  end

  private

  # Converts a command string into a command array.
  # 
  def parse_command_string( arg )
    return arg if arg.kind_of? Array # assume no work needed
    # Otherwise, assume arg is a ς and split it using #each_char
    arg.to_s.each_char.with_object [] do |char, memo|
      # Handle prefix characters:
      ( PREFIX_CHARACTERS.include?(memo[-1]) ? memo[-1] : memo ) << char
    end
  end

  # Initializes method writing flags / state keepers.
  # 
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

  # Writes the skeleton of the method header.
  # 
  def write_method_head_skeleton( ɴ )
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
  
  # Initializes the pipeline (@pipe).
  # 
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
  # 
  def write_method_tail_skeleton
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
  # 
  def write_method_meat
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
  # 
  def autoclose_open_blocks_and_return
    ( rslt = close_block; chain rslt; pipe_2_variable ) while @head.size > 1
    return close_block
  end

  # Called to close a block, including the main def.
  # 
  def close_block
    unless @rr.empty? then @r = @rr.pop end # back with the register
    @pipe.pop; @opener.pop; @finisher.pop   # pop the writing stack
    ( @head.pop + @tail.pop ).join          # join head and tail
  end

  # Writer of argument grab strings.
  # 
  def grab_arg
    msg = "Invalid argument source!"
    @argsrc.source.size == @argsrc.grab_method.size or fail ArgumentError, msg
    grab = case @argsrc.grab_method.last
           when :shift then ".shift"
           when :ref then ""
           when :dup then ".dup"
           else
             msg = "Unknown arg. grab method #{@argsrc.grab_method.last}!"
             fail ArgumentError, msg
           end
    case @argsrc.source.last
    when :args_counted
      x = ( @arg_count += 1 ) - 1
      "args[#{x}]" + grab
    when :args then # now this is a bit difficult, cause
      case @argsrc.grab_method.last   # it's necessary to discard the used
      when :shift then                # args (shift #@arg_count):
        if @arg_count == 0 then
          "args.shift"
        else
          "(args.shift(#@arg_count); args.shift)"
        end
      when :ref then "args"
      else fail TypeError, "Unknown grab method #{@argsrc.grab_method.last}!"
      end
    when :alpha then alpha_touch; 'alpha' + grab
    when :beta then beta_touch; 'beta' + grab
    when :delta, :epsilon, :zeta then @argsrc.source.last.to_s + grab
    when :psi then "args[-2]" + grab
    when :omega then "args[-1]" + grab
    else fail TypeError, "Unknown argument source #{@argsrc.src.last}!"
    end.tap do
      if @argsrc.source.size > 1 then
        @argsrc.source.pop
        @argsrc.grab_method.pop
      end
    end
  end

  # Execution method when in the main def (@w == :main).
  # 
  def main( cmd )
    self.send( cmd )
  end

  # Execution method when in a block (@w == :block).
  # 
  def block( cmd )
    self.send( cmd )
  end

  # *** Method writing subroutines.
  
  # Active register reader.
  # 
  def _r_
    @r
  end

  # Append string to head.
  # 
  def write( x )
    Array( x ).each {|e| @head[-1] << e }
  end

  # Chain (nullary) method string to the end of the pipe.
  # 
  def chain( s )
    @pipe[-1] << ".#{s}"
  end

  # Suck the pipe into the "memory" ⌿- assign its contents to the designated
  # register of the current pipelene.
  # 
  def pipe_2_variable
    @pipe[-1].prepend "#@r = "
    eval "#{@r}_touched = true"
  end

  # Start a new pipe, on a new line. Without arguments, @r is used.
  # 
  def start( s = "#@r" )
    write "\n"; @pipe[-1] = s
    write @pipe.last
  end

  # Set the pipe to a value, discarding current contents.
  # 
  def set( s )
    @pipe[-1].clear << s
  end

  # Store in active register, and continue in a new pipeline.
  # 
  def belay
    pipe_2_variable
    start 
  end

  # Perform pipe_2_variable, execute something else, and go back to @r.
  # 
  def exe( s )
    pipe_2_variable; start s; start
  end

  # Parethesizes the current pipeline.
  # 
  def parenthesize_current_pipeline
    @pipe[-1].prepend("( ") << " )"
  end

  # Write binary operator.
  # 
  def binary_operator( s, x = grab_arg )
    @pipe[-1] << " #{s} " << x
  end

  # Write unary operator.
  # 
  def unary_operator( s )
    parenthesize_current_pipeline
    @pipe[-1].prepend s
  end

  # Returns nothing, or optional block, if flagged to do so.
  # 
  def maybe_block
    case @take_block
    when true then @take_block = :taken; '&block'
    when nil, false, :taken then nil
    else
      fail TypeError, "unexpected @take_block value"
    end
  end

  # Chain unary method.
  # 
  def nullary_method( s )
    chain "#{s}(#{maybe_block})"
  end

  # Chain unary mathod.
  # 
  def unary_method( s, x = grab_arg )
    chain "#{s}( #{[x, maybe_block].compact.join(", ")} )"
  end

  # Chain binary method.
  # 
  def binary_method( s, x = grab_arg, y = grab_arg )
    chain "#{s}( #{[x, y, maybe_block].compact.join(", ")} )"
  end

  # Initiates writing a block method.
  # 
  def nullary_method_with_block( str )
    # puts "in nullary_m_with_block, str = #{str}" # DEBUG
    if @take_block == true then
      nullary_method( str )
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

  # Next block will be written as binary.
  # 
  def next_block_will_be_binary
    @block_arity = 2
  end

  # Next block will be writen as binary with swapped block arguments
  # (delta = zeta; @argsrc.epsilon).
  # 
  def next_block_will_be_binary_with_swapped_arguments
    @block_arity = -2
  end

  # Register 0 (alpha) was ever required for computation.
  # 
  def alpha_touch
    belay unless @alpha_touched or @beta_touched
  end

  # Register 1 (beta) was ever required for the computation.
  # 
  def beta_autoinit
    case @opts.op
    when 1 then s = "beta = self.dup rescue self"
      ( @main_opener.clear << s; @beta_touched = true ) unless @beta_touched
    when 2 then @main_opener.clear << "beta = self[1]" unless @beta_touched
    when -2 then @main_opener.clear << "beta = self[0]" unless @beta_touched
    else raise "wrong @opts[:op] value: #{@opts.op}" end
  end
  alias :beta_touch :beta_autoinit

  # Touch and return the successor of a register, or @r by default.
  # 
  def successor_register reg=@r
    send "#{SUCC[reg]}_touch"
    SUCC[reg]
  end

  # Touch and return the predecessor of a register, or @r by default.
  # 
  def predecessor_register reg=@r
    send "#{PRE[reg]}_touch"
    PRE[reg]
  end
end # class Pyper::PostfixMachine
