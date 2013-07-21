#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require_relative './../lib/pyper'
# require 'pyper'

class PyperTest < ::Test::Unit::TestCase
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
    
    assert_equal [:a, :b, :c], [[:a, 1], [:b, 2], [:c, 3]].τmaτ
    assert_equal ["a", "b", "c"], [[:a, 1], [:b, 2], [:c, 3]].τmatsτ
    
    assert_equal [*(1..7)], [*(1..10)].τuτ
    assert_equal [*(1..8)], [*(1..10)].τvτ
    assert_equal [*(1..9)], [*(1..10)].τwτ
    assert_equal 8, [*(1..10)].τxτ
    assert_equal 9, [*(1..10)].τyτ
    assert_equal 10, [*(1..10)].τzτ


    assert_equal 7, 7.π.τCτ
    assert_equal 7, 7.π.τXτ( 8 )
    assert_equal 8, [7, 8].χCτ
    assert_equal 8, 7.τgτ( 8 )
    
    assert_equal [0, 1, 6, 9], [:x.π.τl0τ, 0.π.τl1τ, Object.new.π.τl6τ, "a".π.τl9τ]
    
    assert_equal [:hello], :hello.π.τAτ
    assert_equal [[:a, 1], [:b, 2]], ( {a: 1, b: 2}.τAτ )
    assert_equal [1, 2], [1, 2].τAτ
    
    assert_equal 1, "+1.000000".τtftiτ
    assert_equal "hello", [:h, ?e, :l, :l, :o].τijτ
    
    assert_equal "la", :la.τtsτ
    
    assert_equal :hello, "hello".τtSτ

    assert_equal [[1, 2]], [1, 2].τtAτ

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

    assert_equal 7, 4.τ₊τ( 3 )
    assert_equal 15, 3.τ★τ( 5 )
    assert_equal 2, 17.τoMτ( 5 )
    assert_equal 17 / 5, 17.τ÷τ( 5 )
    assert_equal true, 7.τEτ( 7 )
    assert_equal [true, false, false], [-1, 0, 1].τm﹤τ( 0, 0, 0 )
    assert_equal [false, false, true], [-1, 0, 1].τm﹥τ( 0, 0, 0 )
    assert_equal [true, true, false], [-1, 0, 1].τmιSτ( 0, 0, 0 )
    assert_equal [false, true, true], [-1, 0, 1].τmιGτ( 0, 0, 0 )
    assert_equal [5, 10, 15], (1..3).τmomτ( 5 )
    assert_equal [1, 4, 9], [*(1..3)].τGDσmomτ
    assert_equal [1, 4, 9], (1..3).τmopτ( 2 )
    assert_equal [1, 4, 9], (1..3).τMomτ
    assert_equal [?a, nil, ?a, nil], (1..4).τmoMEτ( 2, 1 ).τmTτ( ?a, nil )
    assert_equal ["a", nil, "a", nil], (1..4).τmoMETτ( 2, 1, ?a, nil )
    assert_equal [nil, "b", "b", nil], nil.π.τgmETτ( [0, 1, 1, 0], 1, ?b, nil )
    assert_equal [["a", nil], [nil, "b"], ["a", "b"], [nil, nil]],
                 (1..4).τmoMETχ( 2, 1, ?a, nil ).πgmETπ( [0, 1, 1, 0], 1, ?b, nil ).χrZτ
    assert_equal true, [:a, :b, :c].τoiτ( :b )
    assert_equal [[:c], [:a]], [[:b, :c, :d], [:a, :b, :d]].πβoIXo8γosmAτ
                  # χGβmgεoiiEεT_iCχmgεoiiEεT_π( nil, nil ) )
    assert_equal( "d yada yada, a, c blah blah",
                  "%s yada yada, %s blah blah" %
                  [[:d], [:a, :c]].χJXJπ( ", " ) )
    assert_equal "foobar", (1..100).τmoMETχ( 3, 0, "foo", nil ).πmoMETχ( 5, 0, "bar", nil ).πZmijτ[14]
    assert_equal ["ax", "bx"], ["a", "b"].τmτ { |o| o + "x" }
    assert_equal ["ax", "bx"], ["a", "b"].τBmτ { |o| o + "x" }
    assert_equal [-1, -2], [[1, 1], [2, 3]].πMosτ
    assert_equal [1, 2], [[1, 1], [2, 3]].πWosτ
    a, b = [Object.new, Object.new].each { |o| o.define_singleton_method :xxx do "xxx" end }
    hsh = { a => "xxx", b => "xxx" }
    assert_equal hsh, [a, b].τBmXthτ( &:xxx )
    assert_equal [:x], 'x'.τABmτ( &:to_sym )
    assert_equal ['x'], ['x'].τmtS_mtsτ
    assert_equal [[['y']]], [[[:y]]].τmmmtsτ
    assert_equal [[:x, :y], [:v, :w]], [[?x, ?y], [?v, ?w]].τmmtSτ
    
    assert_equal [1, 1, 1], "abc".τml1τ
    require 'y_support/all'
    @a = ["a", "b", "c"]
    exp = [ [["a"], ["b"], ["c"]],
            [["a", "b"], ["c"]],
            [["a"], ["b", "c"]],
            [["a", "b", "c"]] ]
    n = @a.size - 1
    rslt = ( 0 ... 2 ** n ).τmg_MoM_mτ( "%0#{n}b", &[:τmETτ, ?0, ?+,  ?,] )
      .τmpjqJ_moMτ( '', "[@a[%s]]", [ * 0 .. n ] )
      .τmpq_mτ( '[', ']', & method( :eval ) )
    assert_equal exp.sort, rslt.sort
  end
end # class PyperTest
