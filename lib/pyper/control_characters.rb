#coding: utf-8

# PostfixMachine mixin that defines the control characters.
#
module Pyper::ControlCharacters
  PREFIX_CHARACTERS =
    ['t'] <<                     # letter t (for "to_something" methods)
    'o' <<                       # letter o (for operators)
    'l' <<                       # letter l (for literals)
    'i' <<                       # letter i
    'ι' <<                       # greek iota
    '¿' <<                       # inverted question mark
    '‹' <<                       # single left pointing quotation mark
    '›' <<                       # single right pointing quotation mark
    '﹕' <<                       # small colon
    '﹡'                          # small asterisk
end

require_relative 'control_characters/cadr_like'
require_relative 'control_characters/other_latin_letters'
require_relative 'control_characters/greek_letters'
require_relative 'control_characters/other'
