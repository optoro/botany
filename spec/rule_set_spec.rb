require_relative './helper'

describe "a RuleSet" do
  module TestChecks
    def thing_behaves_like_a? klass
      @thing.kind_of? klass
    end

    def thing_equals? thing
      @thing == thing
    end
  end

  class TestRules < Etiquette::RuleSet
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
      where(thing_behaves_like_a?(String)).respond_with(:string)
    end

    Rules.apply_to({thing: "foo"}).must_equal :string
  end

  it "handles multiple rules correctly" do
    Rules = Class.new TestRules do
      where(thing_behaves_like_a?(Numeric)).respond_with(:number)
      where(thing_behaves_like_a?(String)).respond_with(:string)
    end

    Rules.apply_to({thing: 4}).must_equal :number
    Rules.apply_to({thing: "foo"}).must_equal :string
  end

  it "handles composed rules correctly" do
    Rules = Class.new TestRules do
      where(thing_behaves_like_a?(String) & thing_equals?("foo")).respond_with(:bar)
      where(thing_behaves_like_a?(String)).respond_with(:string)
    end

    Rules.apply_to({thing: "foo"}).must_equal :bar
    Rules.apply_to({thing: "baz"}).must_equal :string
    ->() { Rules.apply_to({thing: 4}) }.must_raise Etiquette::RuleNotFoundException
  end
end
