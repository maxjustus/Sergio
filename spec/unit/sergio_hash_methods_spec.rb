require 'spec_helper'

describe Sergio::HashMethods do
  context 'value_at_path' do
    before do
      @s = Class.new do
        include Sergio::HashMethods
      end.new
    end

    it 'gets the value from passed in hash at point in heirarchy specified by passed in array' do
      v = @s.value_at_path([['thing'], ['stuff']], {'thing' => {'stuff' => '2'}})
      v.should == '2'
    end

    it 'gets the value from last hash in array of hashes in passed in hash at point in heirarchy specified by passed in array' do
      v = @s.value_at_path([['thing'], ['stuff']], {'thing' => [{'stuff' => '1'}, {'stuff' => '2'}]})
      v = @s.value_at_path([['thing']], {'thing' => [{'stuff' => '1'}, {'stuff' => '2'}]})
      v.should == [{'stuff' => '1'}, {'stuff' => '2'}]
    end

    it 'gets the value from passed in hash at point in heirarchy specified by passed in array if array is one element long' do
      v = @s.value_at_path([['thing']], {'thing' => {'stuff' => '2'}})
      v.should == {'stuff' => '2'}
    end

    it 'returns nil if value is not present in hash' do
      v = @s.value_at_path(['thing', 'stuff'], {'thing' => {'guy' => '2'}})
      v.should == nil
    end
  end

  context 'hash_recursive_merge_to_arrays' do
    before do
      @s = Class.new do
        include Sergio::HashMethods
      end.new
    end

    it 'merges subhashes together' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guys' => 'cool'}}
      @s.hash_recursive_merge_to_arrays(h1, h2).should == {:thing => {'guy' => 'cool', 'guys' => 'cool'}}
    end

    it 'builds an array out of values on intersecting keys' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guy' => 'cool'}}
      @s.hash_recursive_merge_to_arrays(h1, h2).should == {:thing => {'guy' => ['cool', 'cool']}}
    end

    it 'appends to array if in value of left intersecting key' do
      h1 = {:thing => {'guy' => ['cool', 'neat']}}
      h2 = {:thing => {'guy' => 'cool'}}
      @s.hash_recursive_merge_to_arrays(h1, h2).should == {:thing => {'guy' => ['cool', 'neat', 'cool']}}
    end

    it 'appends to array if in value of right intersecting key' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guy' => ['cool', 'neat']}}
      @s.hash_recursive_merge_to_arrays(h1, h2).should == {:thing => {'guy' => ['cool', 'neat', 'cool']}}
    end
  end

  context 'hash_recursive_merge' do
    before do
      @s = Class.new do
        include Sergio::HashMethods
      end.new
    end

    it 'merges subhashes together' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guys' => 'cool'}}
      @s.hash_recursive_merge(h1, h2).should == {:thing => {'guy' => 'cool', 'guys' => 'cool'}}
    end

    it 'replaces intersecting key values with rightmost hash argument value' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guy' => 'cools'}}
      @s.hash_recursive_merge(h1, h2).should == {:thing => {'guy' => 'cools'}}
    end

    it 'merges new key values into existing hash if one is present' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'neat' => 'cools'}}
      @s.hash_recursive_merge(h1, h2).should == {:thing => {'guy' => 'cool', 'neat' => 'cools'}}
    end
  end

  context 'hash_recursive_append' do
    before do
      @s = Class.new do
        include Sergio::HashMethods
      end.new
    end

    it 'merges subhashes together' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guys' => 'cool'}}
      @s.hash_recursive_append(h1, h2).should == {:thing => {'guy' => 'cool', 'guys' => 'cool'}}
    end

    it 'aggregates intersecting key values into an array' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guy' => 'cools'}}
      @s.hash_recursive_append(h1, h2).should == {:thing => {'guy' => ['cool', 'cools']}}
    end

    it 'aggregates intersecting key values into an array of values where values are not hashes' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'guy' => 'cools'}}
      @s.hash_recursive_append(h1, h2).should == {:thing => {'guy' => ['cool', 'cools']}}
      h1 = {:thing => {'guy' => {'cool' => '1'}}}
      h2 = {:thing => {'guy' => {'cool' => '3'}}}
      @s.hash_recursive_append(h1, h2).should == {:thing => {'guy' => {'cool' => ['1', '3']}}}
    end

    it 'merges new key values into existing hash if one is present' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'neat' => 'cools'}}
      @s.hash_recursive_append(h1, h2).should == {:thing => {'guy' => 'cool', 'neat' => 'cools'}}
    end

    it 'creates an array of hashes at given value if new hash value is an empty hash' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {}}
      @s.hash_recursive_append(h1, h2).should == {:thing => [{'guy' => 'cool'}, {}]}
    end

    it 'merges key values into last hash in existing array of hashes if one is present' do
      h1 = {:thing => {'guy' => 'cool'}}
      h2 = {:thing => {'neat' => 'cools'}}
      h1 = @s.hash_recursive_append(h1, h2)
      h2 = {:thing => {}}
      h1 = @s.hash_recursive_append(h1, h2)
      h1.should == {:thing => [{'guy' => 'cool', 'neat' => 'cools'}, {}]}
      h2 = {:thing => {'guy' => 'cools'}}
      h1 = @s.hash_recursive_append(h1, h2)
      h1.should == {:thing => [{'guy' => 'cool', 'neat' => 'cools'}, {'guy' => 'cools'}]}
      h2 = {:thing => {'neat' => 'cools'}}
      h1 = @s.hash_recursive_append(h1, h2)
      h1.should == {:thing => [{'guy' => 'cool', 'neat' => 'cools'}, {'guy' => 'cools', 'neat' => 'cools'}]}
      h2 = {:thing => {'neat' => 'cools'}}
      h1 = @s.hash_recursive_append(h1, h2)
      h1.should == {:thing => [{'guy' => 'cool', 'neat' => 'cools'}, {'guy' => 'cools', 'neat' => ['cools', 'cools']}]}
      h2 = {:thing => {}}
      h1 = @s.hash_recursive_append(h1, h2)
      h1.should == {:thing => [{'guy' => 'cool', 'neat' => 'cools'}, {'guy' => 'cools', 'neat' => ['cools', 'cools']}, {}]}
      h2 = {:thing => {'hi' => 'hey'}}
      h1 = @s.hash_recursive_append(h1, h2)
      h1.should == {:thing => [{'guy' => 'cool', 'neat' => 'cools'}, {'guy' => 'cools', 'neat' => ['cools', 'cools']}, {'hi' => 'hey'}]}
    end
  end
end
