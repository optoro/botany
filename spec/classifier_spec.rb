require_relative './helper'

describe "a Classifier" do
  module TestChecks
    def thing_behaves_like_a? klass
      @thing.kind_of? klass
    end

    def thing_equals? thing
      @thing == thing
    end
  end

  class TestRules < Botany::Classifier
    checks_with TestChecks
  end

  describe "checks_with" do
    it "constructs an interior RuleContext class" do
      TestRules.subject_class.wont_be_nil
    end

    it "includes into the RuleContext class the methods in the checks module" do
      TestRules.subject_class.instance_methods.include?(:thing_behaves_like_a?).must_equal true
    end
  end

  it "correctly applies a rule" do
    Rules = Class.new TestRules do
      classifies(:string).when thing_behaves_like_a?(String)
    end

    Rules.classify({thing: "foo"}).must_equal :string
  end

  it "can define additional checks" do
    Rules = Class.new TestRules do
      check :thing_is_divisible_by? do |divisor|
        @thing % divisor == 0
      end

      classifies(:even).when thing_is_divisible_by?(2)
    end

    Rules.classify({thing: 6}).must_equal :even
  end

  it "handles multiple rules correctly" do
    Rules = Class.new TestRules do
      classifies(:number).when thing_behaves_like_a?(Numeric)
      classifies(:string).when thing_behaves_like_a?(String)
    end

    Rules.classify({thing: 4}).must_equal :number
    Rules.classify({thing: "foo"}).must_equal :string
  end

  it "handles composed rules correctly" do
    Rules = Class.new TestRules do
      classifies(:bar   ).when thing_behaves_like_a?(String) & thing_equals?("foo")
      classifies(:string).when thing_behaves_like_a?(String)
    end

    Rules.classify({thing: "foo"}).must_equal :bar
    Rules.classify({thing: "baz"}).must_equal :string
    ->() { Rules.classify({thing: 4}) }.must_raise Botany::NoAppropriateRuleException
  end

  it "handles negated rules correctly" do
    Rules = Class.new TestRules do
      classifies(:not_a_string).when !thing_behaves_like_a?(String)
    end

    Rules.classify({thing: 4}).must_equal :not_a_string
  end

  it "handles defaults" do
    Rules = Class.new TestRules do
      classifies(:string).when thing_behaves_like_a?(String)
      classifies(:default)
    end

    Rules.classify({thing: 4}).must_equal :default
  end
end
