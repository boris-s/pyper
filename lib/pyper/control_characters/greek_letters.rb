#coding: utf-8

module Pyper::ControlCharacters
  # Pushes the primary register (alpha) on the argument source stack.
  # 
  def α
    @argsrc.alpha
  end

  # Stashes the contents of the primary pipeline to the argument stack, and
  # sets the secondary register as the argument source.
  # 
  def β
    G()
    r()
  end

  # A combo that switches this an the other register and sets the other register
  # as the argument source.
  # 
  def γ
    X()
    r()
  end

  # Pushes the in-block register (delta) on the argument source stack.
  # 
  def δ
    @argsrc.delta
  end
  
  # Pushes the block argument register 1 (epsilon) on the argument source stack.
  # 
  def ε
    @argsrc.epsilon
  end

  # Pushes the block argument register 2 (zeta) on the argument source stack.
  # 
  def ζ
    @argsrc.zeta
  end  

  # Pushes onto the argument stack the default argument source, which is the
  # "counted argument list" -- Pyper method argument array indexed by
  # compile-time @arg_count index.
  # 
  def λ
    @argsrc.args_counted
  end

  # Pushes the penultimate element of the Pyper method argument array on the
  # argument source stack.
  # 
  def ψ
    @argsrc.psi
  end

  # Pushes the last element of the Pyper method argument array on the argument
  # source stack.
  # 
  def ω
    @argsrc.omega
  end
  
  # Small rho (ρ) sets the +:ref+ grab mode for the argument source stack --
  # that is, turns off +:shift+ or +:dup+ mode when active.
  # 
  def ρ
    @argsrc.ref!
  end

  # Small sigma sets the 'shift' grab mode for the top @argsrc element.
  # 
  def σ
    @argsrc.shift!
  end

  # Capital pi (Π( sets the +:dup+ grab mode for the top @argsrc element.
  # 
  def Π
    @argsrc.dup!
  end

  # Pushes onto the stack the whole array of the arguments passed to the pyper
  # method, with +:shift+ grab method turned on by default.
  # 
  def Ω
    @argsrc.args
  end

  # When Greek iota (ι) is used as the prefix to the source selector, then
  # rather then being pushed on the @argsrc stack, the new argument source
  # replaces the topmost element of the stack. When the stack size is 1, this
  # has the additional effect of setting the given argument source as default,
  # until another such change happens, or stack reset is performed.

  def ια
    @argsrc.alpha!
  end

  def ιβ
    @argsrc.beta!
  end

  # def ιγ; @argsrc.var! successor_register( @rr[0] ) end

  def ιδ
    @argsrc.delta!
  end

  def ιε
    @argsrc.epsilon!
  end

  def ιζ
    @argsrc.zeta!
  end

  # Iota-prefixed rho (ιρ) resets the @argsrc stack to its default contents,
  # that is, size 1 stack with +source:+ +:args_counted+, +grab_method:+ +:ref+.
  # 
  def ιρ
    @argsrc.std!
  end

  def ιψ
    @argsrc.psi!
  end

  def ιω
    @argsrc.omega!
  end

  def ιλ
    @argsrc.args_counted!
  end

  def ιΩ
    @argsrc.args!
  end
end
