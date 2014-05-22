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
    let(:test_classifier) { TestClassifier.new }

    it "constructs an interior RuleContext class" do
      test_classifier.subject_class.wont_be_nil
    end

    it "includes into the RuleContext class the methods in the checks module" do
      test_classifier.subject_class.new({}).respond_to?(:thing_behaves_like_a?).must_equal true
    end
  end

  it "correctly applies a rule" do
    classifier = TestClassifier.new do
      classifies(:string).when thing_behaves_like_a?(String)
    end

    classifier.classify({thing: "foo"}).must_equal :string
  end

  it "can define additional checks" do
    classifier = TestClassifier.new do
      check :thing_is_divisible_by? do |divisor|
        @thing % divisor == 0
      end

      classifies(:even).when thing_is_divisible_by?(2)
    end

    classifier.classify({thing: 6}).must_equal :even
  end

  it "handles multiple rules correctly" do
    classifier = TestClassifier.new do
      classifies(:number).when thing_behaves_like_a?(Numeric)
      classifies(:string).when thing_behaves_like_a?(String)
    end

    classifier.classify({thing: 4}).must_equal :number
    classifier.classify({thing: "foo"}).must_equal :string
  end

  it "handles composed rules correctly" do
    classifier = TestClassifier.new do
      classifies(:bar   ).when thing_behaves_like_a?(String) & thing_equals?("foo")
      classifies(:string).when thing_behaves_like_a?(String)
    end

    classifier.classify({thing: "foo"}).must_equal :bar
    classifier.classify({thing: "baz"}).must_equal :string
    ->() { classifier.classify({thing: 4}) }.must_raise Botany::NoApplicableRule
  end

  it "handles negated rules correctly" do
    classifier = TestClassifier.new do
      classifies(:not_a_string).when !thing_behaves_like_a?(String)
    end

    classifier.classify({thing: 4}).must_equal :not_a_string
  end

  it "handles defaults" do
    classifier = TestClassifier.new do
      classifies(:string).when thing_behaves_like_a?(String)
      default_to(:default)
    end

   classifier.classify({thing: 4}).must_equal :default
  end
end
