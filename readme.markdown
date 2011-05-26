<a href='http://www.youtube.com/watch?v=GaoLU6zKaws'><img src="http://i.imgur.com/HThQt.jpg" alt="" title="Hosted by imgur.com" /></a>
## Sergio is a SAX parser with a handy dsl for transforming xml into hashes

##Usage
    require 'sergio'

    class MyXmlMunger
      include Sergio

      #the hash key will be renamed to the second argument passed to element if one is provided
      element 'body', 'bro' do
        #if a second argument isn't provided it will just use the original name of the element
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

        #Duplicate elements in the same scope are automatically made into an array:
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

###To parse a document into a hash, call parse on an instance of your parsing class with a document string as an argument
    MyXmlMunger.new.parse("<body><id>1</id><a href='dude'>something</a></body>")
    #returns {'bro' => {'id' => '1', 'link' => 'dude'}}

##LICENSE

(The MIT License)

Copyright © 2011:

Max Justus Spransy

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
‘Software’), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
