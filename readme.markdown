[![](http://imgur.com/HThQt.jpg)](http://www.youtube.com/watch?v=GaoLU6zKaws)
### Sergio is a SAX parser with a handy dsl for transforming xml into hashes
    require 'sergio'

    class MyXmlMunger
      include Sergio

      #the element will be renamed to the second argument in the hash if one is provided
      element 'body', 'bro' do
        element 'id'
        #the :attribute option specifies what attribute to draw the value from for the resulting hash
        element 'a', 'link', :attribute => 'href'
        #You can pass a block to #element with a value argument and the hash value will be set to the result of the block
        element 'p', 'content' do |v|
          v.reverse
        end

        #You can pass :having to #element to specify attributes required to match against
        element 'div', 'cars', :having => {'class' => 'car'} do
          #You can pass value and attributes arguments into the block you pass to element
          element 'p', 'description' do |value, attributes|
            "#{value} #{attributes['attribute']}"
          end
        end

        #You can pass arbitrary nestings to match against and merge to
        element ['some', 'nesting'], ['some', 'other', 'nesting']

        #Duplicate elements in the same scope are automatically made into an array,
        element 'some', 'thing'
        #parses
        #<body><some>hey</some><some>hi</some></body>
        #as
        #{'document' => {'thing' => ['hey, 'hi']}}
        #and
        #<body><some>hi</some></body>
        #as
        #{'document' => {'thing' => 'hi'}}

        #You can force arrays for even a single matching element within a given scope using the :as_array option
        element 'some', 'thing', :as_array => true
        #parses
        #<body><some>hi</some></body>
        #as
        #{'document' => {'thing' => ['hi']}}
        #and
        #<body><some>hey</some><some>hi</some></body>
        #as
        #{'document' => {'thing' => ['hey', 'hi']}}
      end
    end

##To parse a document into a hash, call parse on an instance of your parsing class with a document string as an argument
    MyXmlMunger.new.parse("<body><id>1</id><a href='dude'>something</a></body>")
    #returns {'bro' => {'id' => '1', 'link' => 'dude'}}
