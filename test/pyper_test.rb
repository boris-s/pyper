#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require 'pyper'

include Pyper

class YPiperTest < ::Test::Unit::TestCase
  should "define basic methods" do
    assert_equal 1, [1, 2, 3].car
    assert_equal [2, 3], [1, 2, 3].cdr
    assert_equal :a, {a: 1}.caar
    assert_equal [1], {a: 1}.cdar
    assert_equal [:b, 2], {a: 1, b: 2}.cadr
    assert_equal [[:c, 3]], {a: 1, b: 2, c: 3}.cddr
    assert_equal 1, [1, 2].τaτ
    assert_equal 2, [*(1..10)].τbτ
    assert_equal 3, [*(1..10)].τcτ
    assert_equal [*(2..10)], [*(1..10)].τdτ
    assert_equal [*(3..10)], [*(1..10)].τeτ
    assert_equal [*(4..10)], [*(1..10)].τfτ
    
    assert_equal [:a, :b, :c], [[:a, 1], [:b, 2], [:c, 3]].τᴍaτ
    assert_equal ["a", "b", "c"], [[:a, 1], [:b, 2], [:c, 3]].τᴍaSτ
    
    assert_equal [*(1..7)], [*(1..10)].τuτ
    assert_equal [*(1..8)], [*(1..10)].τvτ
    assert_equal [*(1..9)], [*(1..10)].τwτ
    assert_equal 8, [*(1..10)].τxτ
    assert_equal 9, [*(1..10)].τyτ
    assert_equal 10, [*(1..10)].τzτ

    assert_equal 7, 7.τCτ
    assert_equal 7, 7.τχτ( 8 )
    assert_equal 8, [7, 8].χCτ
    assert_equal 8, 7.τ«τ( 8 )
    
    assert_equal [0, 1, 6, 9], [:x.τ∅₀τ, 0.τ∅₁τ, Object.new.τ∅₆τ, "a".τ∅₉τ]
    
    assert_equal [:hello], :hello.τAτ
    assert_equal [[:a, 1], [:b, 2]], ( {a: 1, b: 2}.τAτ )
    assert_equal [1, 2], [1, 2].τAτ
    
    assert_equal 1, "+1.000000".τtiτ
    assert_equal "hello", [:h, ?e, :l, :l, :o].τjτ
    
    assert_equal "la", :la.τstτ
    
    assert_equal :hello, "hello".τsyτ

    assert_equal [[1, 2]], [1, 2].τ⬚τ

    assert_equal [1], [*(1..10)].τ0τ
    assert_equal [1, 2], [*(1..10)].τ1τ
    assert_equal [1, 2, 3], [*(1..10)].τ2τ
    assert_equal [1, 2, 3, 4], [*(1..10)].τ3τ
    assert_equal [1, 2, 3, 4, 5], [*(1..10)].τ4τ
    assert_equal [6, 7, 8, 9, 10], [*(1..10)].τ5τ
    assert_equal [7, 8, 9, 10], [*(1..10)].τ6τ
    assert_equal [8, 9, 10], [*(1..10)].τ7τ
    assert_equal [9, 10], [*(1..10)].τ8τ
    assert_equal [10], [*(1..10)].τ9τ

    assert_equal "lligator", ["See", "you", "later", "alligator"].τdeadτ
    assert_equal ?g, ["See", "you", "later", "alligator"].τdeafbτ

    assert_equal 7, 4.τ⊕τ( 3 )
    assert_equal 15, 3.τ★τ( 5 )
    assert_equal 2, 17.τ⁒τ( 5 )
    assert_equal 17 / 5, 17.τ÷τ( 5 )
    assert_equal true, 7.τiτ( 7 )
    assert_equal [true, false, false], [-1, 0, 1].τᴍofτ( 0, 0, 0 )
    assert_equal [false, false, true], [-1, 0, 1].τᴍogτ( 0, 0, 0 )
    assert_equal [true, true, false], [-1, 0, 1].τᴍohτ( 0, 0, 0 )
    assert_equal [false, true, true], [-1, 0, 1].τᴍoiτ( 0, 0, 0 )
    assert_equal [5, 10, 15], (1..3).τᴍ★τ( 5 )
    assert_equal [1, 4, 9], [*(1..3)].τ»Dσᴍ★τ
    assert_equal [1, 4, 9], (1..3).τᴍ↑τ( 2 )
    assert_equal [1, 4, 9], (1..3).τγZM★τ
    assert_equal [?a, nil, ?a, nil], (1..4).τᴍ⁒iτ( 2, 1 ).τᴍ⁇τ( ?a, nil )
    assert_equal ["a", nil, "a", nil], (1..4).τᴍ⁒i⁇τ( 2, 1, ?a, nil )
    assert_equal [nil, "b", "b", nil], nil.τ«ᴍi⁇τ( [0, 1, 1, 0], 1, ?b, nil )
    assert_equal [["a", nil], [nil, "b"], ["a", "b"], [nil, nil]],
                 (1..4).τᴍ⁒i⁇χ( 2, 1, ?a, nil ).π«ᴍi⁇π( [0, 1, 1, 0], 1, ?b, nil ).χγZτ
    assert_equal true, [:a, :b, :c].τ¿iτ( :b )
    assert_equal( [[:c], [:a]], [[:b, :c, :d], [:a, :b, :d]].
                  χ»βᴍ«ε¿i‼ε⁈ℓn_●χᴍ«ε¿i‼ε⁈ℓn_●π )
    assert_equal( "d yada yada, a, c blah blah",
                  "%s yada yada, %s blah blah" %
                  [[:d], [:a, :c]].χJχJπ( ", " ) )
    assert_equal "fizzbuzz", (1..100).τᴍ⁒i⁇χ( 3, 0, "fizz", nil ).πᴍ⁒i⁇χ( 5, 0, "buzz", nil ).πγZᴍjτ[14]
  end
end # class
