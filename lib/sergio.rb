require 'nokogiri'
require File.dirname(__FILE__) + '/sergio/hash_methods'
require File.dirname(__FILE__) + '/sergio/sergio_sax'
require File.dirname(__FILE__) + '/sergio/sergio_element'
require File.dirname(__FILE__) + '/sergio/sergio_config'
require File.dirname(__FILE__) + '/sergio/sergio_parsed_document'

module Sergio
  def self.included(base)
    base.extend(ClassMethods)
    include(Sergio::HashMethods)
  end

  def sergio_parsed_document
    @sergio_parsed_document ||= Sergio::ParsedDocument.new
  end

  def parse(doc)
    Nokogiri::XML::SAX::Parser.new(SergioSax.new(self)).parse(doc)
    sergio_parsed_document.parsed_hash
  end

  module ClassMethods
    def element(name, newname = nil, args = {}, &blk)
      sergio_config.element(name, newname, args, &blk)
    end

    def sergio_config
      @sergio_config ||= Sergio::Config.new
    end
  end
end
