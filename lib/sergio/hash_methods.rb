module Sergio
  module HashMethods
    def hash_from_path(path, val)
      path = path.clone
      k = path.shift
      h = {}
      h[k] = if path.empty?
        val
      else
        hash_from_path(path, val)
      end
      h
    end

    def value_at_path(path, hash)
      k = path.shift
      k = k.is_a?(Array) ? k[0] : k
      v = hash[k]
      if v
        if v.is_a?(Hash) && path.length > 0
          value_at_path(path, v)
        else
          v
        end
      else
        nil
      end
    end

    def hash_recursive_merge_to_arrays(lval, rval)
      r = {}
      v = lval.merge(rval) do |key, oldval, newval| 
        v = if oldval.class == lval.class
          hash_recursive_merge_to_arrays(oldval, newval) 
        else
          if oldval.is_a?(Array)
            oldval << newval
          elsif newval.is_a?(Array)
            newval << oldval
          else
            [oldval] << newval
          end
        end
        r[key] = v
      end
      v
    end

    #FROM https://gist.github.com/6391/62b6aae9206abe7b3fea6d4659e4c246f8cf7632
    def hash_recursive_merge(lval, rval)
      r = {}
      v = lval.merge(rval) do |key, oldval, newval| 
        r[key] = oldval.class == Hash && newval.class == Hash ? hash_recursive_merge(oldval, newval) : newval
      end
      v
    end
  end
end
