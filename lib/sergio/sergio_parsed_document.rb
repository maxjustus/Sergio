module Sergio
  class ParsedDocument
    include HashMethods
    attr_accessor :parsed_hash

    def initialize
      @parsed_hash = {}
    end

    def set_element(path, val, options = {})
      v = value_at_path(path.clone, self.parsed_hash)

      val = if v
        if v.is_a? Array
          v << val
        else
          if val.is_a?(Hash) && val.empty?
            options[:as_array] ? [v] : v
          else
            [v] << val
          end
        end
      else
        options[:as_array] ? [val] : val
      end

      h = hash_from_path(path, val)
      @parsed_hash = hash_recursive_merge(self.parsed_hash, h)
      @parsed_hash
    end
  end
end
