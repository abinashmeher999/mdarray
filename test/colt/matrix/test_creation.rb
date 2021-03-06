# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require 'rubygems'
require "test/unit"
require 'shoulda'

require 'mdarray'

class MDArrayTest < Test::Unit::TestCase

  context "Colt Matrix" do

    setup do

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create 1D matrices" do

      d1 = MDArray.double([5, 3, 6, 7])
      assert_raise (RuntimeError) { matrix = MDMatrix.from_mdarray(d1) }

      d2 = MDArray.typed_arange("double", 0, 15)
      double_matrix = MDMatrix.from_mdarray(d2)
      double_matrix.print
      printf("\n\n")

      f1 = MDArray.typed_arange("float", 0, 15)
      float_matrix = MDMatrix.from_mdarray(f1)
      float_matrix.print
      printf("\n\n")

      l1 = MDArray.typed_arange("long", 0, 15)
      long_matrix = MDMatrix.from_mdarray(l1)
      long_matrix.print
      printf("\n\n")

      i1 = MDArray.typed_arange("int", 0, 15)
      int_matrix = MDMatrix.from_mdarray(i1)
      int_matrix.print
      printf("\n\n")

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create 3D matrices" do

      d1 = MDArray.double([5, 3, 6, 7])
      assert_raise (RuntimeError) { matrix = MDMatrix.from_mdarray(d1) }

      d2 = MDArray.typed_arange("double", 0, 60)
      d2.reshape!([5, 3, 4])
      double_matrix = MDMatrix.from_mdarray(d2)
      double_matrix.print
      printf("\n\n")

      f1 = MDArray.typed_arange("float", 0, 60)
      f1.reshape!([5, 3, 4])
      float_matrix = MDMatrix.from_mdarray(f1)
      float_matrix.print
      printf("\n\n")

      l1 = MDArray.typed_arange("long", 0, 60)
      l1.reshape!([5, 3, 4])
      long_matrix = MDMatrix.from_mdarray(l1)
      long_matrix.print
      printf("\n\n")

      i1 = MDArray.typed_arange("int", 0, 60)
      i1.reshape!([5, 3, 4])
      int_matrix = MDMatrix.from_mdarray(i1)
      int_matrix.print
      printf("\n\n")

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------
#=begin
    should "create 2D matrices" do

      d1 = MDArray.double([5, 3, 6, 7])
      assert_raise (RuntimeError) { matrix = MDMatrix.from_mdarray(d1) }

      d2 = MDArray.typed_arange("double", 0, 15)
      d2.reshape!([5, 3])
      double_matrix = MDMatrix.from_mdarray(d2)
      double_matrix.print
      printf("\n\n")

      f1 = MDArray.typed_arange("float", 0, 15)
      f1.reshape!([5, 3])
      float_matrix = MDMatrix.from_mdarray(f1)
      float_matrix.print
      printf("\n\n")

      l1 = MDArray.typed_arange("long", 0, 15)
      l1.reshape!([5, 3])
      long_matrix = MDMatrix.from_mdarray(l1)
      long_matrix.print
      printf("\n\n")

      i1 = MDArray.typed_arange("int", 0, 15)
      i1.reshape!([5, 3])
      int_matrix = MDMatrix.from_mdarray(i1)
      int_matrix.print
      printf("\n\n")

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create matrices from sliced MDArray" do

      d1 = MDArray.typed_arange("double", 0, 90)
      d1.reshape!([5, 3, 6])

      d1.print
      d2 = d1.slice(0, 0)
      d2.print
      matrix = MDMatrix.from_mdarray(d2)
      matrix.print
      p " "

      d2 = d1.slice(0, 1)
      d2.print
      matrix = MDMatrix.from_mdarray(d2)
      matrix.print
      p " "

      d2 = d1.slice(1, 1)
      d2.print
      matrix = MDMatrix.from_mdarray(d2)
      matrix.print
      p " "

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create matrices from high order sliced MDArray" do

      d1 = MDArray.typed_arange("double", 0, 420)
      d1.reshape!([5, 4, 3, 7])

      p "three dimensional array"
      d1.print
      matrix = MDMatrix.from_mdarray(d1.slice(0, 0))
      p "two dimensional matrix from given array"
      matrix.print
      p " "

      p "from 4 to two"
      matrix = MDMatrix.from_mdarray(d1.region(:spec => "0:0, 0:0, 0:2, 0:6").reduce)
      matrix.print
      p " "
      matrix.mdarray.print

      # matrix = MDMatrix.from_mdarray(

    end

  end

end
