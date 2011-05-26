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
        if path.length > 0
          if v.is_a?(Hash)
            value_at_path(path, v)
          elsif v.last.is_a?(Hash)
            value_at_path(path, v.last)
          end
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

    def hash_recursive_append(lval, rval)
      r = {}
      v = lval.merge(rval) do |key, oldval, newval|
        r[key] = if oldval.is_a?(Hash) && newval.is_a?(Hash)
          if newval.size == 0
            [oldval, newval]
          else
            hash_recursive_append(oldval, newval)
          end
        else
          if oldval.is_a?(Array)
            if oldval.last.is_a?(Hash) && newval.is_a?(Hash) && newval.size > 0
              oldval << hash_recursive_append(oldval.pop, newval)
            else
              oldval << newval
            end
          elsif newval.is_a?(Array)
            newval << oldval
          else
            [oldval] << newval
          end
        end
      end
      v
    end
  end

  def remove_empty_hashes(hash)
    hash.delete_if do |k,v|
      true
    end
  end
end
