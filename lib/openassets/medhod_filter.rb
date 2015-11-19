module OpenAssets
  module MethodFilter

    module Filters

      def before_filter(method, options = {})
        @before_filters ||= {}
        @before_filters[method] = options
      end

      def filtered_method?(method, options)
        if options.has_key? :include
          return true if options[:include].include? method.intern
          false
        elsif options.has_key? :exclude
          return false if options[:exclude].include? method.intern
          true
        else
          true
        end
      end

      private
      def method_added(name)
        @before_filters ||= {}
        @modified_methods ||= []
        return if @modified_methods.include?(name)
        return if @before_filters.include?(name)
        return if /with_filters$/ =~ name.to_s
        return if  /without_filters$/ =~ name.to_s
        @modified_methods << name

        name = name.to_s
        alias_method( "#{name}_without_filters", name)
        before_filters = @before_filters

        define_method("#{name}_with_filters") do |*args|
          before_filters.each do |filter_name, options|
            method(filter_name).call if self.class.filtered_method?(name, options)
          end
          result = method("#{name}_without_filters").call(*args)
          result
        end

        alias_method(name, "#{name}_with_filters")
        @modified_methods.delete_if { |x| name == x }
      end
    end

    def self.included(receiver)
      receiver.extend(Filters)
    end

  end
end