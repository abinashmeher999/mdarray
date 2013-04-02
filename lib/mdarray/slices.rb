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

class MDArray

  #------------------------------------------------------------------------------------
  # Create a copy of this Array, copying the data so that physical order is the same as 
  # logical order
  #------------------------------------------------------------------------------------

  def copy
    MDArray.new(@nc_array.copy())
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def reshape(shape, copy = false)

    new_shape = shape.to_java :int

    if (copy)
      nc_array = @nc_array.reshape(new_shape)
    else
      nc_array = @nc_array.reshapeNoCopy(new_shape)
    end

    MDArray.new(@type, nc_array)

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def reshape!(shape)
    new_shape = shape.to_java :int
    @nc_array = @nc_array.reshapeNoCopy(new_shape)
    # when we reshape an array we need to re-initialize its index and local_iterator
    @local_index = Counter.new(self)
    @local_iterator = nil
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def reduce(dim = nil)

    if (dim)
      nc_array = @nc_array.reduce(dim.to_java :int)
    else
      nc_array = @nc_array.reduce
    end
    
    shape = MDArray.get_shape(nc_array)
    MDArray.new(@type, nc_array)
    
  end

  #---------------------------------------------------------------------------------------
  # Create a new Array using same backing store as this Array, by permuting the indices.
  # Parameters:
  # <tt>indices</tt> the old index dims[k] becomes the new kth index.
  # Returns:
  # the new Array
  # Throws:
  # IllegalArgumentException: - wrong rank or dim[k] not valid
  #---------------------------------------------------------------------------------------

  def permute(indices)

    ind = indices.to_java :int
    
    begin
      perm = @nc_array.permute(ind)
    rescue # should catch IllegalArgumentException
      raise "Illegal argument"
    end

    MDArray.new(@type, perm)

  end

  #------------------------------------------------------------------------------------
  # Create a new Array as a subsection of this Array, without rank reduction. No data 
  # is moved, so the new Array references the same backing store as the original.
  # Parameters:
  # origin - int array specifying the starting index. Must be same rank as original Array.
  # shape - int array specifying the extents in each dimension. This becomes the shape 
  # of the returned Array. Must be same rank as original Array.
  # stride - int array specifying the strides in each dimension. If null, assume all ones.
  # Returns:
  # the new Array
  # Throws:
  # InvalidRangeException - if ranges is invalid
  #------------------------------------------------------------------------------------

  def section(origin, shape, reduce = false)

    jorigin = origin.to_java :int
    jshape = shape.to_java :int

    if (reduce)
      arr = @nc_array.section(jorigin, jshape)
    else
      arr = @nc_array.sectionNoReduce(jorigin, jshape, nil)
    end

    # this is an array section, set it to true
    if (arr.rank == 0)
      return arr.get()
    end

    section = MDArray.new(@type, arr, true)
    copy_print_parameters(section)
    return section

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def section_with_stride(origin, shape, stride, reduce = false)

    jorigin = origin.to_java :int
    jshape = shape.to_java :int
    jstride = stride.to_java :int

    if (reduce)
      arr = @nc_array.section(jorigin, jshape, jstride)
    else
      arr = @nc_array.sectionNoReduce(jorigin, jshape, jstride)
    end

    # this is an array section, set it to true
    section = MDArray.new(@type, arr, true)
    copy_print_parameters(section)
    return section

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def section?
    @section
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  private

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def section=(value)
    @section = value
  end

end