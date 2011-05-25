require 'spec_helper'

describe Sergio do
  context 'element' do
    it 'parses an element' do
      s = new_sergio do
        element 'id'
      end

      @xml = "<id>1</id>"
      @hash = s.new.parse(@xml)
      @hash['id'].should == '1'
    end

    it 'parses duplicate elements into an array' do
      s = new_sergio do
        element 'parent' do
          element 'id'
        end
      end

      @xml = "<parent><id>1</id><id>2</id></parent>"
      @hash = s.new.parse(@xml)
      @hash['parent']['id'].should == ['1', '2']
    end

    it 'parses duplicate elements whose callbacks return a hash into an array' do
      s = new_sergio do
        element 'parent' do
          element 'id' do |v|
            {'v' => v}
          end
        end
      end

      @xml = "<parent><id>1</id><id>2</id></parent>"
      @hash = s.new.parse(@xml)
      @hash['parent']['id'].should == [{'v' => '1',}, {'v' => '2'}]
    end

    it 'parses a nested element' do
      s = new_sergio do
        element 'ip' do
          element 'man'
        end
      end

      @xml = "<ip><man>neat</man></ip>"
      @hash = s.new.parse(@xml)
      @hash['ip']['man'].should == 'neat'
    end

    it 'renames an element to second argument passed to #element if argument is provided' do
      s = new_sergio do
        element 'man', 'guy'
      end

      @xml = "<man>neat</man>"
      @hash = s.new.parse(@xml)
      @hash['guy'].should == 'neat'
    end

    it 'passes value into block if block has an arity of 1. And sets element value to block result' do
      s = new_sergio do
        element 'man' do |v|
          v.reverse
        end
      end

      @xml = "<man>neat</man>"
      @hash = s.new.parse(@xml)
      @hash['man'].should == 'taen'
    end

    it 'passes value and attributes into block if block has an arity of 2 and sets element value to block result' do
      s = new_sergio do
        element 'man' do |v, attrs|
          {'u' => attrs['it'], 'v' => v.reverse}
        end
      end

      @xml = "<man it='u'>neat</man>"
      @hash = s.new.parse(@xml)
      @hash['man'].should == {'u' => 'u', 'v' => 'taen'}
    end

    it 'renames a parent element to second argument passed to #element if argument is provided' do
      s = new_sergio do
        element 'parent', 'post' do
          element 'id'
        end
      end

      @xml = "<parent><id>1</id><id>2</id></parent>"
      @hash = s.new.parse(@xml)
      @hash['post'].should == {'id' => ['1', '2']}
    end

    it 'renames a child element to second argument passed to #element if argument is provided' do
      s = new_sergio do
        element 'parent', 'post' do
          element 'id', 'di'
        end
      end

      @xml = "<parent><id>1</id><id>2</id></parent>"
      @hash = s.new.parse(@xml)
      @hash['post'].should == {'di' => ['1', '2']}
    end

    it 'matches against attributes using :having argument' do
      s = new_sergio do
        element 'parent', 'post' do
          element 'ya', 'kewl', :attribute => 'location', :having => {:href => 'cool', :poopy => 'true'}
        end
      end

      @xml = "<parent><ha href='imahref'>neat</ha><ha href='cool'>rad</ha><ya href='cool' poopy='true' location='my house'>wee</ya></parent>"
      @hash = s.new.parse(@xml)
      @hash['post']['kewl'].should == 'my house'
    end

    it 'forces aggregation of matching results into an array even for one match if passed :as_array => true' do
      s = new_sergio do
        element 'parent', 'post' do
          element 'ya', 'kewl', :attribute => 'location', :having => {:href => 'cool', :poopy => 'true'}, :as_array => true
        end
      end

      @xml = "
        <parent>
          <ha href='imahref'>neat</ha>
          <ha href='cool'>rad</ha>
          <ya href='cool' poopy='true' location='my house'>wee</ya>
        </parent>"
      @hash = s.new.parse(@xml)
      @hash['post']['kewl'].should == ['my house']
    end

    it 'matches against multiple elements within same parent' do
      s = new_sergio do
        element 'parent', 'post' do
          element 'ha', 'link', :having => {:href => 'cool'} do |val|
            val.reverse
          end
          element 'ya', 'kewl', :attribute => 'location', :having => {:href => 'cool', :poopy => 'true'}
        end
      end

      @xml = "<parent>
        <ha href='imahref'>neat</ha>
        <ha href='cool'>rad</ha><ya href='cool' poopy='true' location='my house'>wee</ya>
      </parent>"

      @hash = s.new.parse(@xml)
      @hash['post']['link'].should == 'dar'
      @hash['post']['kewl'].should == 'my house'
    end

    it 'matches against multiple elements of the same type within same parent' do
      s = new_sergio do
        element 'p' do
          element 'a', :attribute => 'href' do |v|
            v.upcase
          end
          element 'a', :attribute => 'cool' do |v|
            v.upcase
          end
        end
      end

      @xml = "<p><a href='cool'>hi</a><a cool='true'>hy</a></p>"
      @hash = s.new.parse(@xml)
      @hash['p']['a'].should == ['COOL','TRUE']
    end

    it 'uses value of attribute using :attribute argument' do
      s = new_sergio do
        element 'a', 'link', :attribute => 'href'
      end

      @xml = "<a href='neat'>neat</a>"
      @hash = s.new.parse(@xml)
      @hash['link'].should == 'neat'
    end

    it 'accepts an array as the first argument to specify a path to an element' do
      s = new_sergio do
        element ['a', 'b'], 'c', :attribute => 'y'
      end

      @xml = '<a><b y="what"></b></a>'
      @hash = s.new.parse(@xml)
      @hash['c'].should == 'what'
    end

    it 'accepts an array as the second argument to specify a path to an element to merge to' do
      s = new_sergio do
        element 'a', ['b', 'c'], :attribute => 'y'
      end

      @xml = '<a y="what"></a>'
      @hash = s.new.parse(@xml)
      @hash['b'].should == {'c' => 'what'}
    end

    it 'accepts an array for both arguments to specify a path to an element to get value from and to  merge to' do
      s = new_sergio do
        element 'p' do
          element 'd'
          element ['a', 'b'], ['b', 'c'], :attribute => 'y'
          element 'a'
        end
      end

      @xml = '<p><d>a</d><a y="what"><b y="hi"></b></a></p>'
      @hash = s.new.parse(@xml)
      @hash['p']['b'].should == {'c' => 'hi'}
    end

    it 'accepts a class which includes sergio as an argument' do
      class Pozt
        include Sergio

        element 'b'
      end

      s = new_sergio do
        element 'a', Pozt
      end

      @xml = '<a y="what"><b>hi</b></a>'
      @hash = s.new.parse(@xml)
      @hash['a']['b'].should == {'c' => 'what'}
    end
  end

  context 'set_element' do
    before do
      @s = new_sergio
    end

    it 'sets the element at the appropriate point in the hierarchy' do
      v = @s.new.sergio_parsed_document.set_element(['thing', 'stuff'], '1')
      v.should == {'thing' => {'stuff' => '1'}}
    end
  end
end
