class SergioSax < Nokogiri::XML::SAX::Document
  def initialize(object)
    @stack = []
    @object = object
  end

  def start_element(name, attrs = [])
    @stack << [name, attrs]
  end

  def characters(string)
    name, attrs = @stack.last
    attrs << ['@text', string]
  end

  def cdata_block(string)
    characters(string)
  end
  
  def end_element(name)
    e_context = @stack.clone
    name, attrs = @stack.pop
    if sergio_elements = @object.class.sergio_config.get_element_configs(e_context)
      sergio_elements.each do |sergio_element|
        attr = sergio_element.options[:attribute]
        val = attrs.assoc(attr)
        if val
          val = val[1]
          hash_path = sergio_element.new_path
          callback = sergio_element.callback

          r = if callback.arity == 1
            callback.call(val)
          elsif callback.arity == 2
            h = Hash[*attrs.flatten]
            h.delete('@text')
            callback.call(val, Hash[*attrs.flatten])
          end

          @object.sergio_parsed_document.set_element(hash_path, r, sergio_element.options)
        end
      end
    end
  end
end
