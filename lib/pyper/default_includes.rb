# encoding: utf-8

class Object
  # Method π is defined on Object, that enables Pyper method calls.
  # 
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

# Pyper is by default included in Enumerable.
# 
module Enumerable
  include Pyper
end

# Pyper is by default included in Array.
# 
class Array
  include Pyper
end

# Pyper is by default included in Hash.
# 
class Hash
  include Pyper
end

# Pyper is by default included in Range.
# 
class Range
  include Pyper
end

# Pyper is by default included in String.
# 
class String
  include Pyper
end

