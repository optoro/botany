require_relative './helper'

describe "a Classifier" do
  module TestChecks
    def thing_behaves_like_a? klass
      @thing.kind_of? klass
    end

    def thing_equals? other_thing
      @thing == other_thing
    end
  end

  class TestClassifier < Botany::Classifier
    checks_with TestChecks
  end

  describe "checks_with" do
    it "constructs an interior RuleContext class" do
      TestClassifier.subject_class.wont_be_nil
    end

    it "includes into the RuleContext class the methods in the checks module" do
      TestClassifier.subject_class.new({}).respond_to?(:thing_behaves_like_a?).must_equal true
    end
  end

  it "correctly applies a rule" do
    Classifier = Class.new TestClassifier do
      classifies(:string).when thing_behaves_like_a?(String)
    end

    Classifier.classify({thing: "foo"}).must_equal :string
  end

  it "can define additional checks" do
    Classifier = Class.new TestClassifier do
      check :thing_is_divisible_by? do |divisor|
        @thing % divisor == 0
      end

      classifies(:even).when thing_is_divisible_by?(2)
    end

    Classifier.classify({thing: 6}).must_equal :even
  end

  it "handles multiple rules correctly" do
    Classifier = Class.new TestClassifier do
      classifies(:number).when thing_behaves_like_a?(Numeric)
      classifies(:string).when thing_behaves_like_a?(String)
    end

    Classifier.classify({thing: 4}).must_equal :number
    Classifier.classify({thing: "foo"}).must_equal :string
  end

  it "handles composed rules correctly" do
    Classifier = Class.new TestClassifier do
      classifies(:bar   ).when thing_behaves_like_a?(String) & thing_equals?("foo")
      classifies(:string).when thing_behaves_like_a?(String)
    end

    Classifier.classify({thing: "foo"}).must_equal :bar
    Classifier.classify({thing: "baz"}).must_equal :string
    ->() { Classifier.classify({thing: 4}) }.must_raise Botany::NoApplicableRuleException
  end

  it "handles negated rules correctly" do
    Classifier = Class.new TestClassifier do
      classifies(:not_a_string).when !thing_behaves_like_a?(String)
    end

    Classifier.classify({thing: 4}).must_equal :not_a_string
  end

  it "handles defaults" do
    Classifier = Class.new TestClassifier do
      classifies(:string).when thing_behaves_like_a?(String)
      default_to(:default)
    end

    Classifier.classify({thing: 4}).must_equal :default
  end
end
