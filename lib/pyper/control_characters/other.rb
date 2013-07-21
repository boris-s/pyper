#coding: utf-8

module Pyper::ControlCharacters
  # Nullary method join.
  # 
  def ij
    chain "join"
  end

  # Unary + operator.
  # 
  def ip
    unary_operator "+"
  end

  # Unary - operator.
  # 
  def im
    unary_operator "-"
  end

  # Unary tilde operator.
  # 
  def it
    unary_operator "~"
  end

  # Unary method +#index+.
  # 
  def ix
    unary_method "index"
  end

  # Nullary method +#compact+.
  # 
  def iC
    nullary_method "compact"
  end

  # Nullary method bang (+#!+, exclamation mark operator).
  # 
  def iE
    unary_operator '!'
  end

  # Map with index
  # 
  def iX
    next_block_will_be_binary
    nullary_method "map"
    nullary_method_with_block "with_index"
  end

  # Stands for Float( register ).
  # 
  def tf
    pipe_2_variable
    start "Float( #@r )"
  end

  # Make a hash out of the current register.
  # 
  def th
    pipe_2_variable
    start "Hash[ #@r.zip( #{successor_register(@r)} ) ]"
  end

  # Stands for Integer( register ).
  # 
  def ti
    pipe_2_variable
    start "Integer( #@r )"
  end

  # Stands for +#to_s+.
  # 
  def ts
    nullary_method "to_s"
  end

  # Make a singleton array out of the current register. ("Array( register ) is
  # invoked simply by capital A without prefixes.)
  # 
  def tA
    pipe_2_variable
    start "[#@r]"
  end

  # Zips this and other register to a hash.
  # 
  def tH
    pipe_2_variable
    start "Hash[ #@r.zip( #{successor_register( @r )} ) ]"
  end

  # Stands for +#to_sym+.
  # 
  def tS
    nullary_method "to_sym"
  end

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
  
  # Maps the other register to this register.
  # 
  def iM
    pipe_2_variable
    start "#{successor_register(@r)}"
    nullary_method_with_block "map"
  end

  def ᴘ # make a pair
    pipe_2_variable
    arg = grab_arg
    start "[#@r, #{arg}]"
  end
  
  # Addition as unary method.
  # 
  def oa
    binary_operator "+"
  end
  alias ₊ oa # subscript plus (₊)

  # Unary method +#include?+.
  # 
  def oi
    unary_method "include?"
  end

  # Subtraction as unary method.
  # 
  def os
    binary_operator "-"
  end
  alias ₋ os # subscript minus (₋)

  # Multiplication as unary method.
  # 
  def om
    binary_operator "*"
  end
  alias ★ om

  # Division as unary method.
  # 
  def od
    binary_operator "/"
  end
  alias ÷ od

  # Power as unary method.
  # 
  def op
    binary_operator "**"
  end
  alias ﹡﹡ op

  # And operator (+#&&+, double pretzel) method.
  # 
  def oA
    binary_operator "&&"
  end

  # Operator triple equals (+#===+).
  # 
  def oA
    binary_operator "==="
  end

  # Pipe operator (+#|+) method.
  # 
  def oI
    binary_operator "|"
  end

  # Smaller than as unary method.
  # 
  def oS
    binary_operator "<"
  end
  alias ﹤ oS

  # Greater than as unary method.
  # 
  def oG
    binary_operator ">"
  end
  alias ﹥ oG

  # Modulo operator as unary method (also used for string interpolation).
  # 
  def oM
    binary_operator "%"
  end

  # Or operator (+#||+, double pipe) method.
  # 
  def oO
    binary_operator "||"
  end

  # Pretzel operator (+#&+) method.
  # 
  def o8
    binary_operator "&"
  end

  # Smaller or equal as unary method.
  # 
  def ιS
    binary_operator "<="
  end

  # Greater or equal as unary method.
  # 
  def ιG
    binary_operator ">="
  end

  # Braces equals method, +#[]=+.
  # 
  def ιI
    @pipe[-1] << "[#{grab_arg}] = #{grab_arg}"
  end
  
  # Misc
  # ********************************************************************
  
  # def ru; end                    # unsh/prep reg 2 self (this changed)
  # def rv; end                    # <</app reg 2 self (this changed)
  # def rU; end                    # unsh/prep reg 2 self (other changed)
  # def rV; end                    # <</app reg 2 self (other changed)
  
  # def su; end                    # unsh/prep self 2 arg
  # def sv; end                    # <</app self 2 arg
  
  # def sy; nullary_method "to_sym" end
  
  # # sA: ? prependmap other, this, switch to other
  # # sB: ? appendmap other, this, switch to other
  
  # def sU; end                    # 
  # def sV; end
  
  # Argument-setting literal +nil+.
  # 
  def ιn
    exe "args.unshift %s" % "nil"
  end
  
  # Argument-setting literal +''+.
  # 
  def ις;
    exe "args.unshift %s" % ''
  end
  
  # Argument-setting literal +[]+.
  # 
  def ιA
    exe "args.unshift %s" % '[]'
  end
  
  # Argument-setting literal +{}+.
  # 
  def ιH
    exe "args.unshift %s" % '{}'
  end
  
  # Pipe-resetting literal +nil+.
  # 
  def ln
    set "nil"
  end

  # Pipe-resetting literal empty string +''+.
  # 
  def lς
    set ''
  end

  # Pipe-resetting literal empty array +[]+.
  # 
  def lA
    set '[]'
  end

  # Pipe-resetting literal empty hash +{}+.
  # 
  def lH
    set '{}'
  end
  
  # Pipe-resetting literal digit 0.
  # 
  def l0
    set "0"
  end

  # Pipe-resetting literal digit 1.
  # 
  def l1
    set "1"
  end

  # Pipe-resetting literal digit 2.
  # 
  def l2
    set "2"
  end

  # Pipe-resetting literal digit 3.
  # 
  def l3
    set "3"
  end

  # Pipe-resetting literal digit 4.
  # 
  def l4
    set "4"
  end

  # Pipe-resetting literal digit 5.
  # 
  def l5
    set "5"
  end

  # Pipe-resetting literal digit 6.
  # 
  def l6
    set "6"
  end

  # Pipe-resetting literal digit 7.
  # 
  def l7
    set "7"
  end

  # Pipe-resetting literal digit 8.
  # 
  def l8
    set "8"
  end

  # Pipe-resetting literal digit 9.
  # 
  def l9
    set "9"
  end

  # Clear the current pipe (set to empty string):
  def ∅; set "" end
  alias :⊘ :∅                      # similarly looking circled slash
  alias :ø :∅                      # similarly looking Danish ø
end
