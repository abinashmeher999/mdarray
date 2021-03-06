# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation for educational, research, and 
# not-for-profit purposes, without fee and without a signed licensing agreement, is hereby 
# granted, provided that the above copyright notice, this paragraph and the following two 
# paragraphs appear in all copies, modifications, and distributions. Contact Rodrigo
# Botafogo - rodrigo.a.botafogo@gmail.com for commercial licensing opportunities.
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


##########################################################################################
#
##########################################################################################

class LazyMDArray < ByteMDArray
  include_package "ucar.ma2"
  include_package "org.codehaus.janino"

  attr_reader :stack

  #=======================================================================================
  # Class BinaryComp applies a function f to two arguments.  The arguments can be
  # functions on their own right
  #=======================================================================================

  class BinaryComp

    def initialize(f, x, y, *args)
      @x = x
      @y = y
      @f = f
      @other_args = args
    end
    
    def apply
      @f.apply(@x.apply, @y.apply)
    end

  end # BinaryComp

  #=======================================================================================
  # Class UnaryComp applies a function f to one arguments.  The arguments can be a
  # function on its own right
  #=======================================================================================

  class UnaryComp

    def initialize(f, x, *args)
      @x = x
      @f = f
      @other_args = args
    end
    
    def apply
      @f.apply(@x.apply)
    end

  end # UnaryComp

  #=======================================================================================
  #
  #=======================================================================================


  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def initialize

    @stack = Array.new
    @type = "lazy"
    @previous_binary_operator = nil
    @previous_unary_operator = nil

  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def push(elmt)
    @stack << elmt
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def pop
    @stack.pop
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def test_janino_function
    $exp = ExpressionEvaluator.new
    $exp.setExpressionType(Java::CernColtFunctionTdouble::DoubleFunction.java_class)
    class_type = Java::JavaLang::Class.forName("java.lang.Class")
    array = Java::JavaLangReflect::Array.newInstance(class_type, 2)
    array[0] = Java::double.java_class
    array[1] = Java::double.java_class
    $exp.setParameters(["a", "b"].to_java(:string), 
                       array)
    $exp.cook("a + b")
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def apply(*args)

    type, shape, function = validate_fast(args)

    result = MDArray.build(type, shape)
    helper = Java::RbMdarrayLoopsLazy::DefaultLazyOperator
    helper.send("apply", result.nc_array, function)
    result

  end

  alias :[] :apply

  #---------------------------------------------------------------------------------------
  # Shows this LazyMDArray in Reverse Polish Notation. Mainly for debugging purposes.
  #---------------------------------------------------------------------------------------

  def rpn(nl = true)
 
    exp = String.new

    @stack.each do |elmt|

      if (elmt.is_a? LazyMDArray)
        exp << elmt.rpn(false)
      elsif (elmt.is_a? Numeric)
        exp << elmt << " "
      elsif (elmt.is_a? Operator)
        exp << elmt.name << " "
      elsif (elmt.is_a? MDArray)
        exp << elmt.type << " "
      else
        raise "Wrong element type in Array"
      end

    end

    exp

  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def print
    Kernel.print "[Lazy MDArray]\n"
    p rpn
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  protected

  #---------------------------------------------------------------------------------------
  # Validates the expression checking if it can be performed: all dimensions need to be
  # compatible
  #---------------------------------------------------------------------------------------

  def validate_fast(*args)

    # test_janino_function
    # p "validade_fast compile janino expression:"
    # $exp.apply(100, 100)

    helper_stack = Array.new

    @stack.each do |elmt|

      if (elmt.is_a? LazyMDArray)
        helper_stack << elmt.validate_fast(*args)
      elsif (elmt.is_a? MDArray)
        # helper_stack << [elmt.type, elmt.shape, index_func(elmt)]
        # iterator = elmt.nc_array.getIndexIterator
        java_proc = Java::RbMdarrayUtil::Util.getIterator(elmt.nc_array)
        helper_stack << [elmt.type, elmt.shape, java_proc]
      elsif (elmt.is_a? Numeric)
        # const_func is inefficient... fix!!!
        helper_stack << ["numeric", 1, const_func(elmt)]
      elsif (elmt.is_a? Operator)
        case elmt.arity
        when 1
          top = helper_stack.pop
          fmap = MDArray.select_function(elmt.name, MDArray.functions, top[0],
                                         top[0], "void")
          helper_stack << 
            [top[0], top[1], 
             # UnaryComp.new(top[2], fmap.function, elmt.other_args)]
             Java::RbMdarrayUtil::Util.compose(fmap.function, top[2])]
        when 2
          top1, top2 = helper_stack.pop(2)
          if (top1[1] != top2[1] && top1[0] != "numeric" && top2[0] != "numeric")
            raise "Expression involves incopatible arrays. #{top1[1]} != #{top2[1]}"
          end
          type = MDArray.upcast(top1[0], top2[0])
          fmap = MDArray.select_function(elmt.name, MDArray.functions, type, type, type)
          helper_stack << 
            [type, top1[1], 
             Java::RbMdarrayUtil::Util.compose(fmap.function, top1[2], top2[2])]
        end
      else
        raise "Expression is invalid: element #{elmt} is not valid in this position."
      end
      
    end
    
    helper_stack[0]

  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  private

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def const_func(val)
    Proc.new { |index| val }
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def index_func(a)
    Proc.new { |index| a.jget(index) }
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------

  def get_next_func(a)
    Proc.new { a.getObjectNext() }
  end

  #---------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------
  
  def binary_function_next(proc1, proc2, f, *args)
    Proc.new { f.call(proc1.apply, proc2.apply, *args) }
  end

end # LazyMDArray

##########################################################################################
#
##########################################################################################

class MDArray

  #---------------------------------------------------------------------------------------
  # 
  #---------------------------------------------------------------------------------------

  def self.set_lazy(flag = true)

    if (flag)
      if (MDArray.binary_operator != LazyBinaryOperator)
        MDArray.previous_binary_operator = MDArray.binary_operator
        MDArray.previous_unary_operator = MDArray.unary_operator
      end
      MDArray.binary_operator = LazyBinaryOperator
      MDArray.unary_operator = LazyUnaryOperator
    else
      MDArray.binary_operator = MDArray.previous_binary_operator if MDArray.previous_binary_operator != nil
      MDArray.unary_operator = MDArray.previous_unary_operator if MDArray.previous_unary_operator != nil
    end

  end

  #---------------------------------------------------------------------------------------
  # 
  #---------------------------------------------------------------------------------------

  def self.lazy=(flag)
    set_lazy(flag)
  end

end

require_relative 'lazy_operators'
