
# encoding: UTF-8
module EasyType
  STRING_OF_DIGITS = /^\d+$/
  #
  # Contains a set of generic validators to be used in any custo type
  #
  module Validators
    ##
    #
    # This validator validates if a name is free of whitespace and not empty. To use this validator, include
    # it in a Puppet name definition.
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::NameValidator
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module Name
      # @private
      def unsafe_validate(value)
        fail Puppet::Error, "Name must not contain whitespace: #{value}" if value =~ /\s/
        fail Puppet::Error, 'Name must not be empty' if value.empty?
      end
    end

    ##
    #
    # This validator validates if it is an Integer
    #
    # @example
    #
    #    newparam(:name) do
    #      include EasyType::Validators::Integer
    #
    # @param value of the parameter of property
    # @raise [Puppet::Error] when the name is invalid
    #
    module Integer
      # @private
      def unsafe_validate(value)
        fail Puppet::Error, "Invalid integer value: #{value}" unless value =~ STRING_OF_DIGITS
      end
    end
  end
end
