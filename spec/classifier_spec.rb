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
      TestRules.rule_context_class.wont_be_nil
    end

    it "includes into the RuleContext class the methods in the checks module" do
      TestRules.rule_context_class.instance_methods.include?(:thing_behaves_like_a?).must_equal true
    end
  end

  it "correctly applies a rule" do
    Rules = Class.new TestRules do
      classify(:string).when thing_behaves_like_a?(String)
    end

    Rules.apply_to({thing: "foo"}).must_equal :string
  end

  it "can define additional checks" do
    Rules = Class.new TestRules do
      check :thing_is_divisible_by? do |divisor|
        @thing % divisor == 0
      end

      classify(:even).when thing_is_divisible_by?(2)
    end

    Rules.apply_to({thing: 6}).must_equal :even
  end

  it "handles multiple rules correctly" do
    Rules = Class.new TestRules do
      classify(:number).when thing_behaves_like_a?(Numeric)
      classify(:string).when thing_behaves_like_a?(String)
    end

    Rules.apply_to({thing: 4}).must_equal :number
    Rules.apply_to({thing: "foo"}).must_equal :string
  end

  it "handles composed rules correctly" do
    Rules = Class.new TestRules do
      classify(:bar   ).when thing_behaves_like_a?(String) & thing_equals?("foo")
      classify(:string).when thing_behaves_like_a?(String)
    end

    Rules.apply_to({thing: "foo"}).must_equal :bar
    Rules.apply_to({thing: "baz"}).must_equal :string
    ->() { Rules.apply_to({thing: 4}) }.must_raise Botany::NoAppropriateRuleException
  end

  it "handles negated rules correctly" do
    Rules = Class.new TestRules do
      classify(:not_a_string).when !thing_behaves_like_a?(String)
    end

    Rules.apply_to({thing: 4}).must_equal :not_a_string
  end

  it "handles defaults" do
    Rules = Class.new TestRules do
      classify(:string).when thing_behaves_like_a?(String)
      classify(:default)
    end

    Rules.apply_to({thing: 4}).must_equal :default
  end
end
