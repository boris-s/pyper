#coding: utf-8

module Pyper::ControlCharacters
  # In Pyper, 'car' becomes 'τaτ', and means second elements. Usable with
  # strings, too.
  # 
  def a; pipe_2_variable; start "#@r =\n" +
      "if #@r.respond_to?( :first ) then #@r.first\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0]\n" +
      "else raise 'impossible to extract first element' end"
    start
  end

  # Means second element.
  # 
  def b; pipe_2_variable; start "#@r =\n" +
      "if #@r.respond_to?( :take ) then #@r.take(2)[1]\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[1]\n" +
      "else raise 'unable to extract second collection element' end"
    start
  end    

  # Means third element.
  # 
  def c; pipe_2_variable; start "#@r =\n" +
      "if #@r.respond_to?( :take ) then #@r.take(3)[2]\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[2]\n" +
      "else raise 'unable to extract third collection element' end"
    start
  end    

  # In Pyper, 'cdr' becomes 'τdτ'.
  # 
  def d; pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop(1) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop(1)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[1..-1]\n" +
      "else raise 'unable to #drop(1) or #[1..-1]' end"
    start
  end

  # Means all except the first 2 elements.
  # 
  def e; pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop(2) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop(2)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[2..-1]\n" +
      "else raise 'unable to #drop(2) or #[2..-1]' end"
    start
  end

  # Means all except the first 3 elements.
  # 
  def f; pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop(3) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop(3)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[3..-1]\n" +
      "else raise 'unable to #drop(3) or #[3..-1]' end"
    start
  end

  # Means the last collection element.
  # 
  def z; pipe_2_variable; start "#@r =\n" +
      "if #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 1 ).first\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-1]\n" +
      "else raise 'unable to extract last element' end"
    start
  end

  # Means the penultimate collection element.
  # 
  def y; pipe_2_variable; start "#@r =\n" +
      "if #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 2 ).first\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-2]\n" +
      "else raise 'unable to extract second-from-the-end element' end"
    start
  end

  # Means the third collection element from the end.
  # 
  def x; pipe_2_variable; start "#@r =\n" +
      "if #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 3 ).first\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-3]\n" +
      "else raise 'unable to extract third-from-the-end element' end"
    start
  end

  # Whole collection except the last element,
  # 
  def w; pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.take( #@r.size - 1 ) ]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take( #@r.size - 1 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0...-1]\n" +
      "else raise 'unable to #drop(1) or #[1...-1]' end"
    start
  end

  # Collection except the last 2 elements.
  # 
  def v; pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.take( #@r.size - 2 ) ]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take( #@r.size - 2 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0...-2]\n" +
      "else raise 'unable to #drop(1) or #[1...-2]' end"
    start
  end

  # Collection except the last 3 elements.
  # 
  def u; pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.take( #@r.size - 3 ) ]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take( #@r.size - 3 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0...-3]\n" +
      "else raise 'unable to #drop(1) or #[1...-3]' end"
    start
  end

  # Control character '0' means a singleton array containing the 1st element.
  # of the collection.
  # 
  self.send :define_method, :'0' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[@r.take(1)]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take(1)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0..0]\n" +
      "else raise 'unable to #take(1) or #[0..0]' end"
    start
  end

  # Control character '1' means an array containing the [1st, 2nd] elements.
  # 
  self.send :define_method, :'1' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[@r.take(2)]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take(2)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0..1]\n" +
      "else raise 'unable to #take(2) or #[0..1]' end"
    start
  end

  # Control character '2' means an array of [1st, 2nd, 3rd] elements.
  # 
  self.send :define_method, :'2' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[@r.take(3)]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take(3)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0..2]\n" +
      "else raise 'unable to #take(3) or #[0..2]' end"
    start
  end

  # Control character '3' means an array of [1st, 2nd, 3rd, 4th] elements.
  # 
  self.send :define_method, :'3' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[@r.take(4)]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take(4)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0..3]\n" +
      "else raise 'unable to #take(4) or #[0..3]' end"
    start
  end

  # Control character '4' means an array of [1st, 2nd, 3rd, 4th, 5th] elements.
  # 
  self.send :define_method, :'4' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[@r.take(5)]\n" +
      "elsif #@r.respond_to?( :take ) then #@r.take(5)\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[0..4]\n" +
      "else raise 'unable to #take(5) or #[0..4]' end"
    start
  end

  # Control char. '5' means an array of [-5th, -4th, -3rd, -2nd, -1st] elements
  # (that is, the last 5 elements).
  # 
  self.send :define_method, :'5' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 5 ) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 5 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-5..-1]\n" +
      "else raise 'unable to take last 5 or call #[-5..-1]' end"
    start
  end

  # Control char. '6' means an array of [-4th, -3rd, -2nd, -1st] elements (that
  # is, the last 4 elements).
  # 
  self.send :define_method, :'6' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 4 ) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 4 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-4..-1]\n" +
      "else raise 'unable to take last 4 or call #[-4..-1]' end"
    start
  end

  # Control char. '7' means an array of [-3rd, -2nd, -1st] elements (that is,
  # the last 3 elements).
  # 
  self.send :define_method, :'7' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 3 ) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 3 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-3..-1]\n" +
      "else raise 'unable to take last 3 or call #[-3..-1]' end"
    start
  end

  # Control char. '8' means an array of [-2nd, -1st] elements (that is, the last
  # 2 elements).
  # 
  self.send :define_method, :'8' do
    pipe_2_variable; start "#@r =\n" +
      "if #@r.is_a?( Hash ) then Hash[ @r.drop( #@r.size - 2 ) ]\n" +
      "elsif #@r.respond_to?( :drop ) then #@r.drop( #@r.size - 2 )\n" +
      "elsif #@r.respond_to?( :[] ) then #@r[-2..-1]\n" +
      "else raise 'unable to take last 2 or call #[-2..-1]' end"
    start
  end

  # Control char. '9' means a singleton array containing the last element of a
  # collection.
  # 
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
  # statement. Also, these methods cannot be invoked by ordinary means,
  # only by explicit message passing. This limitation is fine for this
  # particular usecase.)
end # class Pyper::ControlCharacters
