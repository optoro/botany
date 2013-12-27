# Etiquette

Etiquette is an abstract contextual rules engine. It helps you manage
complex decision trees related to your data models without cluttering them.

## Installation

Add this line to your application's Gemfile:

    gem 'etiquette'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install etiquette

## Usage

We first need conditions (to see if we should apply a given rule):
```ruby
module OurConditions
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
class OurRules < Etiquette::RuleSet
  checks_with OurConditions

  where(thing_behaves_like_a?(String)).respond_with(:string)
  where(thing_behaves_like_a?(Numeric)).respond_with(:number)
end
```

And finally, application:
```ruby
OurRules.apply_to({thing: 4}) # returns :number
OurRules.apply_to({thing: "4"}) # returns :string
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
