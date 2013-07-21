class Pyper::PostfixMachine
  # Compile-time argument source stack. To explain, the default source of
  # arguments in compiled Pyper methods is 'args' local variable, containing
  # all the arguments supplied to the method (as in +method(*args)+ call).
  # However, this default argument source can be changed to something else.
  # For this purpose, compil-time argument source stack is maintained, showing
  # where the next argument will come from. It is implemented as a struct with
  # two arrays: +source+ and +grab_method+. The source shows where the argument
  # comes from, and grab method shows how is it obtained. There are 3 possible
  # ways to obtain an argument from a source:
  #
  # * :ref -- by reference (ie. by simply taking it)
  # * :dup -- by duplication (calling #dup method on the source)
  # * :shift -- by shifting (calling #shift method on the source)
  # 
  # As for the sources, there may be the following ones in a compiled method:
  # 
  # * :args -- whole argument array
  # * :args_counted -- args referenced with compile time counter -- default
  # * :alpha -- primary pipeline
  # * :beta -- secondary pipeline
  # * :delta -- in-block pipeline
  # * :epsilon -- block argument 0
  # * :zeta -- block argument 1
  # * :psi -- penultimate element in the args array; penultimate argument
  # * :omega -- last element in the args array; last argument
  # 
  # We can se that +:args_counted+ source comes as if with its own special
  # grabbing method. At compile time, +PostfixMachine+ maintains @args_count
  # attribute, an index to the +args+ array, and increments it each time
  # an argument is taken. Other argument sources do not have counters and
  # if they contain arrays, they can only be grabbed by the standard three
  # methods.
  # 
  class ArgumentSource < Struct.new( :source, :grab_method )
    class << self
      # Initially, argument stack has a single layer with +:args_counted+ as
      # the source, and +:ref+ as grab method.
      # 
      def new
        self[ [:args_counted], [:ref] ]
      end
    end

    # Resets the stack back to the initial condition.
    # 
    def std!
      self.source = [:args_counted]
      self.grab_method = [:ref]
    end

    # Modifies the topmost grab method on the stack to +:shift+.
    # 
    def shift!
      grab_method[-1] = :shift
    end

    # Modifies the topmost grab method on the stack to +:ref+.
    # 
    def ref!
      grab_method[-1] = :ref
    end

    # Modifies the topmost grab method on the stack to +:dup+.
    # 
    def dup!
      grab_method[-1] = :dup
    end

    # Pushes +:args_counted+ source and +:ref+ grab method on the stack.
    # 
    def args_counted
      source.push :args_counted
      grab_method.push :ref
    end

    # Modifies the topmost source on the stack to +:args_counted+, leaving grab
    # method unchanged.
    # 
    def args_counted!
      source[-1] = :args_counted
    end

    # Pushes +:args+ source and +:shift+ grab method on the stack.
    # 
    def args
      source.push :args
      grab_method.push :shift
    end

    # Modifies the topmost source on the stack to +:args+, and grab method to
    # +:shift+.
    # 
    def args!
      source[-1] = :args
      shift!
    end

    # Pushes on the stack a given variable name as the source, and +:ref+ as the
    # grab method.
    # 
    def var variable
      source.push variable
      grab_method.push :ref
    end

    # Modifies the topmost source on the stack to the given variable name,
    # leaving the grab method unchanged.
    # 
    def var! variable
      source[-1] = variable
    end

    # Pushes +:alpha+ source and +:ref+ grab method on the stack.
    # 
    def alpha
      var :alpha
    end

    # Modifies the topmost source on the stack to +:alpha+, leaving the grab
    # method unchanged.
    # 
    def alpha!
      var! :alpha
    end

    # Pushes +:beta+ source and +:ref+ grab method on the stack.
    # 
    def beta
      var :beta
    end

    # Modifies the topmost source on the stack to +:beta+, leaving the grab
    # method unchanged.
    # 
    def beta!
      var! :beta
    end

    # Pushes +:delta+ source and +:ref+ grab method on the stack.
    # 
    def delta
      var :delta
    end

    # Modifies the topmost source on the stack to +:delta+, leaving the grab
    # method unchanged.
    # 
    def delta!
      var! :delta
    end

    # Pushes +:epsilon+ source and +:ref+ grab method on the stack.
    # 
    def epsilon
      var :epsilon
    end

    # Modifies the topmost source on the stack to +:epsilon+, leaving the grab
    # method unchanged.
    # 
    def epsilon!
      var! :epsilon
    end

    # Pushes +:zeta+ source and +:ref+ grab method on the stack.
    # 
    def zeta
      var :zeta
    end

    # Modifies the topmost source on the stack to +:zeta+, leaving the grab
    # method unchanged.
    # 
    def zeta!
      var! :zeta
    end

    # Pushes +:psi+ source and +:ref+ grab method on the stack.
    # 
    def psi
      var :psi
    end

    # Modifies the topmost source on the stack to +:psi+, leaving the grab
    # method unchanged.
    # 
    def psi!
      var! :psi
    end

    # Pushes +:omega+ source and +:ref+ grab method on the stack.
    # 
    def omega
      var :omega
    end

    # Modifies the topmost source on the stack to +:omega+, leaving the grab
    # method unchanged.
    # 
    def omega!
      var! :omega
    end
  end
end # class Pyper::PostfixMachine::ArgumentSource
