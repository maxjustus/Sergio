module Sergio
  class ParsedDocument
    include HashMethods
    attr_accessor :parsed_hash

    def initialize
      @parsed_hash = {}
    end

    def set_element(path, val, options = {})
      old_val = value_at_path(path.clone, self.parsed_hash)

      if options[:as_array] && !val.is_a?(Array) && !old_val.is_a?(Array)
        val = [val]
      end

      h = hash_from_path(path, val)
      @parsed_hash = hash_recursive_append(self.parsed_hash, h)
      @parsed_hash
    end
  end
end
