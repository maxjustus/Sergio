module Sergio
  class Element
    attr_accessor :new_path, :callback, :options
    def initialize(new_path, args, callback)
      @new_path = new_path.clone
      @callback = callback
      @options = args
    end
  end
end
