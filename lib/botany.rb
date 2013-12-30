require 'botany/version'

module Botany
  class Classifier
    def self.checks_with checks_module
      rule_context_class.send :include, checks_module
    end

    def self.check name, &definition
      rule_context_class.send :define_method, name, &definition
    end

    def self.rule_context_class
      if const_defined? :RuleContext
        const_get :RuleContext
      else
        const_set :RuleContext, Class.new(Botany::Context)
      end
    end

    def self.classify classification
      (rules << Botany::Rule.new(classification)).last
    end

    def self.method_missing sym, *args, &blk
      is_check?(sym) ? CheckSet.new(sym, *args) : super
    end

    def self.rules
      @rules ||= []
    end

    def self.is_check? sym
      @check_tester ||= rule_context_class.new({})

      @check_tester.respond_to? sym
    end

    def self.apply_to hash
      context = rule_context_class.new hash

      if rule = rule_for_context(context)
        rule.classification
      else
        raise NoAppropriateRuleException
      end
    end

    def self.rule_for_context context
      rules.find do |rule|
        rule.appropriate_in_context? context
      end
    end
  end

  NoAppropriateRuleException = Class.new StandardError

  class Rule
    def initialize classification
      @classification = classification
    end

    attr_reader :check_set, :classification

    def when check_set
      @check_set = check_set
    end

    def appropriate_in_context? context
      @check_set ? @check_set.appropriate_in_context?(context) : true
    end
  end

  class CheckSet
    def initialize *args
      @checks = [Check.new(*args)]
      @invert_appropriateness = false
    end

    attr_reader :checks, :invert_appropriateness

    def appropriate_in_context? context
      invert_appropriateness ? false_in_context?(context) : true_in_context?(context)
    end

    def true_in_context? context
      checks.each do |check|
        return false unless check.true_in_context?(context)
      end
    end

    def false_in_context? context
      !true_in_context?(context)
    end

    def & check_set
      @checks.concat check_set.checks
      self
    end

    def !
      @invert_appropriateness = !invert_appropriateness
      self
    end
  end

  class Check
    def initialize *args
      @proc = Proc.new { send *args }
    end

    attr_reader :proc

    def true_in_context? context
      context.instance_eval &proc
    end
  end

  class Context
    def initialize hash
      hash.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end
  end
end
