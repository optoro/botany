# Botany

Botany is an abstract classification engine. It helps you manage
complex decision trees related to your data models without cluttering
them.

## Installation

Add this line to your application's Gemfile:

    gem 'botany'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install botany

## Usage

We first need checks (to see if we should apply a given rule):
```ruby
module OurChecks
  def thing_behaves_like_a? klass
    @thing.kind_of? klass
  end

  def thing_equals? thing
    @thing == thing
  end
end
```

Now we can build our rules:
```ruby
class OurClassifier < Botany::Classifier
  checks_with OurChecks

  classifies(:string).when thing_behaves_like_a?(String)
  classifies(:number).when thing_behaves_like_a?(Numeric)
end
```

And finally, application:
```ruby
OurClassifier.classify({thing: 4}) # returns :number
OurClassifier.classify({thing: "4"}) # returns :string
```

Pretty cool, no?

Setting a default response is simple:
```ruby
class OurClassifier
  ...
  default_to :none_of_those_things
end
```

You can also compose your checks:
```ruby
  classifies(:bar).when thing_behaves_like_a?(String) & thing_equals('foo')
```

And negate them:
```ruby
  classifies(:not_a_string).when !thing_behaves_like_a?(String)
```

We can also define individual checks inside the Classifier:
```ruby
  check :thing_is_divisible_by? do |divisor|
    @thing % divisor == 0
  end
```

One should note, however, that these must be defined before they can
be used in invocations of ```when```.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
