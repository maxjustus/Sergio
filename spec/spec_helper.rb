require 'rspec'
require File.dirname(__FILE__) + '/../lib/sergio'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

def new_sergio(&blk)
  c = Class.new do
    include Sergio
  end
  if block_given?
    c.class_exec(&blk)
  end
  c
end
