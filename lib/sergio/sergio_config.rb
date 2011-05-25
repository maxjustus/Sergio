module Sergio
  class Config
    include HashMethods
    attr_accessor :sergio_elements, :new_path, :current_path
    def initialize
      @parsing_elements = {}
      @new_path, @current_path = [], []
    end

    def element(name, newname = nil, args = {}, &blk)
      if newname.is_a?(Hash)
        args = newname
        newname = nil
      end

      args = args.inject({}) do |args, k_v|
        args[k_v[0].to_sym] = k_v[1]
        args
      end

      args[:attribute] ||= '@text'
      args[:having] ||= false
      newname = name unless newname
      name = [name] unless name.is_a?(Array)
      newname = [newname] unless newname.is_a?(Array)

      name.each do |n|
        @current_path << n
      end

      newname.each do |n|
        @new_path << n
      end

      unless block_given?
        blk = lambda do |val|
          val
        end
      end

      #block with more calls to #element
      if blk.arity < 1
        blk.call
        callback = lambda {|v|{}}
      else
        callback = blk
      end

      elem = SergioElement.new(new_path, args, callback)

      @parsing_elements = hash_recursive_merge_to_arrays(@parsing_elements, hash_from_path(current_path, {:sergio_elem => elem}))
      current_path.pop(name.length)
      new_path.pop(newname.length)
    end

    def get_element_configs(path)
      path = path.clone
      current_elem = path.last
      v = value_at_path(path, @parsing_elements)
      if v
        v = v[:sergio_elem]
        if v
          v = [v] if v.is_a?(SergioElement)
          vs = v.select do |v|
            if v.options[:having]
              match = v.options[:having].any? do |attr,value|
                current_elem_attrs = current_elem[1]
                elem_val = current_elem_attrs.assoc(attr.to_s)
                elem_val[1] == value.to_s if elem_val
              end
              true if match
            else
              true
            end
          end
          vs
        end
      end
    end
  end
end
