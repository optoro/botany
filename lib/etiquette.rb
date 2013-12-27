module Etiquette
  class RuleSet
    def self.checks_with checks_module
      rule_context_class.send :include, checks_module
    end

    def self.rule_context_class
      if const_defined? :RuleContext
        const_get :RuleContext
      else
        const_set :RuleContext, Class.new(Etiquette::Context)
      end
    end

    def self.where check_set
      (rules << Etiquette::Rule.new(check_set)).last
    end

    def self.method_missing sym, *args, &blk
      if is_check? sym
        CheckSet.new sym, *args
      else
        super
      end
    end

    def self.rules
      @rules ||= []
    end

    def self.is_check? sym
      rule_context_class.instance_methods.include? sym
    end

    def self.apply_to hash
      context = rule_context_class.new hash

      if rule = rule_for_context(context)
        rule.target
      else
        raise RuleNotFoundException
      end
    end

    def self.rule_for_context context
      rules.find do |rule|
        rule.appropriate_in_context? context
      end
    end
  end

  RuleNotFoundException = Class.new StandardError

  class Rule
    def initialize check_set
      @check_set = check_set
    end

    attr_reader :check_set, :target

    def respond_with target
      @target = target
    end

    def appropriate_in_context? context
      @check_set.true_in_context? context
    end
  end

  class CheckSet
    def initialize sym, *args
      @checks = [Check.new(sym, *args)]
    end

    attr_reader :checks

    def true_in_context? context
      checks.map do |check|
        check.true_in_context? context
      end.all?
    end

    def & check_set
      @checks.concat check_set.checks
      self
    end
  end

  class Check
    def initialize sym, *args
      @proc = Proc.new { send sym, *args }
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
