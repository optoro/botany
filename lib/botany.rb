require 'botany/version'

module Botany
  class Classifier
    def self.checks_with checks_module
      subject_class.send :include, checks_module
    end

    def self.check name, &definition
      subject_class.send :define_method, name, &definition
    end

    def self.subject_class
      if const_defined? :RuleSubject
        const_get :RuleSubject
      else
        const_set :RuleSubject, Class.new(Botany::Subject)
      end
    end

    def self.classifies classification
      (rules << Botany::Rule.new(classification)).last
    end

    def self.default_to classification
      rules << Botany::DefaultRule.new(classification)
    end

    def self.defaults_to classification
      default_to classification
    end

    def self.method_missing sym, *args, &blk
      is_check?(sym) ? CheckSet.new(sym, *args) : super
    end

    def self.rules
      @rules ||= []
    end

    def self.is_check? sym
      @check_tester ||= subject_class.new({})

      @check_tester.respond_to? sym
    end

    def self.classify hash
      subject = subject_class.new hash

      if rule = rule_for_subject(subject)
        rule.classification
      else
        raise NoApplicableRuleException
      end
    end

    def self.rule_for_subject subject
      rules.find do |rule|
        rule.applies_to_subject? subject
      end
    end
  end

  NoApplicableRuleException = Class.new StandardError

  class Rule
    def initialize classification
      @classification = classification
    end

    attr_reader :check_set, :classification

    def when check_set
      @check_set = check_set
    end

    def applies_to_subject? subject
      @check_set ? @check_set.applies_to_subject?(subject) : true
    end
  end

  class DefaultRule
    def initialize classification
      @classification = classification
    end

    attr_reader :classification

    def applies_to_subject? subject
      true
    end
  end

  class CheckSet
    def initialize *args
      @checks = [Check.new(*args)]
      @invert_applicability = false
    end

    attr_reader :checks, :invert_applicability

    def applies_to_subject? subject
      invert_applicability ? false_for_subject?(subject) : true_for_subject?(subject)
    end

    def true_for_subject? subject
      checks.each do |check|
        return false unless check.true_for_subject?(subject)
      end
    end

    def false_for_subject? subject
      !true_for_subject?(subject)
    end

    def & check_set
      @checks.concat check_set.checks
      self
    end

    def !
      @invert_applicability = !invert_applicability
      self
    end
  end

  class Check
    def initialize *args
      @proc = Proc.new { send *args }
    end

    attr_reader :proc

    def true_for_subject? subject
      subject.instance_eval &proc
    end
  end

  class Subject
    def initialize hash
      hash.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end
  end
end
