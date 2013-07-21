#coding: utf-8

module Pyper::ControlCharacters
  # Current pipe is assigned with the argument from the argument source.
  # 
  def g
    set grab_arg
  end

  # Other pipe is assigned with the argument from the argument source.
  # 
  def h
    exe "#@r, #{successor_register(@r)} = #{successor_register(@r)}, #@r"
    set grab_arg
    exe "#@r, #{successor_register(@r)} = #{successor_register(@r)}, #@r"
  end

  # Compiler directive that decrements the @arg_count index. With +:args_counted+
  # argument source, when used once, causes the same argument to be taken twice.
  # When used twice or more, causes the same number of argument array elements to
  # be taken twice.
  # 
  def j
    @arg_count -= 1
  end

  # k:

  # l:

  # def m; nullary_method_with_block "map" end # All-important #map method

  def m
    pipe_2_variable
    start "if #@r.is_a? String then #@r = #@r.each_char end\n"
    start
    nullary_method_with_block "map"
  end
  
  # n:
  # o: prefix character

  # Adaptive prepend.
  # 
  def p
    pipe_2_variable; arg = grab_arg; start "#@r =\n" + # arg 2 self
      "if #@r.respond_to?( :unshift ) then #@r.unshift(#{arg})\n" +
      "elsif #@r.respond_to?( :prepend ) then #@r.prepend(#{arg})\n" +
      "elsif #@r.respond_to?( :merge ) and #@r.is_a?( Array ) " +
      "&& #@r.size == 2\nHash[*#@r].merge(#{arg})\n" +
      "elsif #@r.respond_to? :merge then #@r.merge(#{arg})\n" +
      "else raise 'impossible to unshift/prepend' end"
    start
  end

  # Adaptive append.
  # 
  def q
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

  # Pushes the secondary register (beta) onto the argument source stack.
  # 
  def r
    @argsrc.beta
  end

  # Sends the argument from the argument source to the current pipeline.
  # 
  def s
    pipe_2_variable
    start "#@r.send( *({grab_arg}) )"
  end

  # t: prefix character
  
  # Latin capital letters
  # ********************************************************************
  # Applies +#Array+ method to the register.
  # 
  def A
    pipe_2_variable
    start "Array( #@r )"
  end
  alias Α A # Greek Α, looks the same, different char

  # Makes the next block-enabled method receive the block that was supplied to
  # the Pyper method.
  # 
  def B
    @take_block = true unless @take_block == :taken
  end

  # Explicit parenthesizing of the current pipeline.
  # 
  def C
    parenthesize_current_pipeline
  end

  # Explicit dup-ping of the current pipeline (Giving up the original object
  # and working with its +#dup+ instead.)
  # 
  def D
    exe "#@r = #@r.dup"
  end

  # Equals operator (+:==+).
  # 
  def E
    binary_operator "=="
  end

  # F:

  # Ungrab the argument (unshift from pipeline).
  # 
  def G
    exe "args.unshift #@r"
  end

  # A combo that switches this and other register, ungrabs the argument,
  # and sets the other register as the argument source.
  # 
  def H
    X()
    β()
  end

  # Braces method, +#[]+.
  # 
  def I
    @pipe[-1] << "[#{grab_arg}]"
  end


  # I:

  # +#join+ expecting argument.
  # 
  def J
    unary_method "join"
  end

  # K:

  # L:

  # Zip this and other register and invoke +#map+ with a binary block on it.
  # 
  def M
    next_block_will_be_binary
    pipe_2_variable
    start "#@r.zip(#{successor_register(@r)})"
    nullary_method_with_block "map"
  end

  # N:

  # O: prefix character (ready to append literal)

  # P: recursive piper method, begin

  # Q: recursive piper method, end

  def R # Reverse zip: Zip other and this register
    pipe_2_variable
    start "#{rSUCC}.zip(#@a)"
  end

  # S:

  # Ternary operator as binary method with the current pipeline as the receiver.
  # 
  def T
    parenthesize_current_pipeline
    @pipe[-1] << " ? ( #{grab_arg} ) : ( #{grab_arg} )"
  end

  # Unshift / prepend this register to the other register.
  # 
  def U; end                     # unsh/prep self 2 reg (other changed)

  def V; end                     # <</app self 2 reg (other changed)

  # Map zipped other and this register using binary block.
  # 
  def W
    next_block_will_be_binary    # Mnemonic: W is inverted M
    pipe_2_variable
    start "#{successor_register(@r)}.zip(#@r)"
    nullary_method_with_block "map"
  end

  # Swaps the contents of the primary (alpha) and the secondary (beta) register.
  # 
  def X
    case @w
    when :block then raise "'χ' (swap pipes) may not be used in blocks!"
    else
      exe "#@r, #{successor_register} = #{successor_register}, #@r"
    end
  end

  # Y:

  # Zip this and other register.
  # 
  def Z
    pipe_2_variable
    start "#@r.zip(#{successor_register})"
  end
end
