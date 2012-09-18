# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pyper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["boris"]
  gem.email         = ["\"boris@iis.sinica.edu.tw\""]
  gem.description   = %q{Ruby extension of Lispy #car/#cdr methods.}
  gem.summary       = %q{Methods car, cdr, caar, cadr, cdar, caaar, caadr, ... are well known from Lisp.
  Here, 'a' means first element of a collection, 'd' means rest of the collection. Now, imagine that there
  would also be 'b' and 'c', meaning 2nd and 3rd element, 'e', 'f', meaning rest minus first 2, resp. first
  3 elements. Imagine that instead of starting 'c' and ending 'r', Greek letter τ would be used: τaτ, τdτ, ...
  to distinguish Pyper methods in the namespace. Imagine more more letters for more methods, imagine that
  these methods can have arity higher than 0, imagine double-barrel pipeline instead of just single-barrel,
  and you are getting to the spirit of Pyper (and APL).}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pyper"
  gem.require_paths = ["lib"]
  gem.version       = Pyper::VERSION
  
  gem.add_development_dependency "shoulda"
end
