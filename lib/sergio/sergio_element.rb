module Sergio
  class Element
    attr_accessor :new_path, :callback, :options, :aggregate_element
    def initialize(new_path, args, callback, aggregate_element)
      @new_path = new_path.clone
      @callback = callback
      @options = args
      @aggregate_element = aggregate_element
    end
  end
end
