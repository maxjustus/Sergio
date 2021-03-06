class SergioSax < Nokogiri::XML::SAX::Document
  def initialize(object)
    @stack = []
    @object = object
    @current_configs = []
    @parent_callbacks = []
  end

  def start_element(name, attrs = [])
    attrs = Hash[*attrs.flatten]
    @stack << [name, attrs]
    if current_configs = @object.class.sergio_config.get_element_configs(@stack)
      current_configs.each do |c|
        if c.aggregate_element
          @parent_callbacks << lambda do
            @object.sergio_parsed_document.set_element(c.new_path, {}, c.options)
          end
        end
      end
    end
  end

  def characters(string)
    name, attrs = @stack.last
    attrs['@text'] = attrs.fetch('@text', '') + string
  end

  def cdata_block(string)
    characters(string)
  end
  
  def end_element(name)
    current_configs = @object.class.sergio_config.get_element_configs(@stack)
    name, attrs = @stack.pop
    if current_configs
      current_configs.each do |c|
        attr = c.options[:attribute]
        val = attrs[attr]
        callback = c.callback

        if val && !c.aggregate_element
          r = if callback.arity == 1
            callback.call(val)
          elsif callback.arity == 2
            attrs.delete('@text')
            callback.call(val, attrs)
          end

          #only builds parent elements if at least one of their child elements has a match
          @parent_callbacks.each do |c|
            c.call
          end
          @parent_callbacks = []

          #build an array of hashes if return value from callback is a hash
          @object.sergio_parsed_document.set_element(c.new_path, {}, c.options) if r.is_a?(Hash)
          @object.sergio_parsed_document.set_element(c.new_path, r, c.options)
        end
      end
    end
    @parent_callbacks = []
  end
end
