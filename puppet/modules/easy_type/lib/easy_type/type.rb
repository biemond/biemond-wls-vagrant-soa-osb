# encoding: UTF-8
require 'easy_type/group'

module EasyType
  #
  # This module contains all extensions used by EasyType within the type
  #
  # To use it, include the following statement in your type
  #
  #   include EasyType::Type
  #
  module Type
    # @private
    def self.included(parent)
      parent.extend(ClassMethods)
    end

    def method_missing(meth, *args, &block)
      variable = meth.to_sym
      if known_attribute(variable)
        self[variable]
      else
        super # You *must* call super if you don't handle the
              # method, otherwise you'll mess up Ruby's method
              # lookup.
      end
    end

    # @private
    def respond_to?(meth, include_private = false)
      variable = meth.to_sym
      if known_attribute(variable)
        true
      else
        super
      end
    end

    #
    # Return the groups the type contains
    #
    # @return [Group] All defined groups
    #
    def groups
      self.class.groups
    end

    #
    # Return the defined commands for the type
    #
    # @return [Array] of [Symbol] with all commands
    #
    def commands
      self.class.instance_variable_get(:@commands)
    end

    private

    # @private
    def known_attribute(attribute)
      all_attributes = self.class.properties.map(&:name) + self.class.parameters
      all_attributes.include?(attribute)
    end

    # @nodoc
    module ClassMethods
      #
      # define a group of parameters. A group means a change in one of
      # it's members all the information in the group is added tot
      # the command
      #
      # @example
      #  group(:name) do # name is optional
      #     property :a
      #     property :b
      #  end
      # @param [Symbol] group_name the group name to use. A group name must be unique within a type
      # @return [Group] the defined group
      #
      # rubocop:disable Alias
      def group(group_name = :default, &block)
        include EasyType::FileIncluder

        @group_name = group_name # make it global
        @groups ||= EasyType::Group.new

        alias :orig_parameter :parameter
        alias :orig_property :property

        def parameter(parameter_name)
          process_group_entry(include_file("puppet/type/#{name}/#{parameter_name}"))
        end

        def property(property_name)
          process_group_entry(include_file("puppet/type/#{name}/#{property_name}"))
        end

        def process_group_entry(entry)
          @groups.add(name, entry)
        end

        yield if block

        alias :parameter :orig_parameter
        alias :property :orig_property
      end
      # rubocop:enable Alias
      #
      # Return the groups the type contains
      #
      # @return [Group] All defined groups
      #
      def groups
        @groups ||= EasyType::Group.new
        @groups
      end
      #
      # include's the parameter declaration. It searches for the parameter file in the directory
      # `puppet/type/type_name/parameter_name
      #
      # @example
      #  parameter(:name)
      #
      # @param [Symbol] parameter_name the base name of the parameter
      #
      def parameter(parameter_name)
        include_file "puppet/type/#{name}/#{parameter_name}"
      end
      alias_method :property, :parameter

      #
      # set's the command to be executed. If the specified argument translate's to an existing
      # class method on the type, this method will be identified as the command. When a class
      # method doesn't exist, the command will be translated to an os command
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    command do
      #     :sql
      #    end
      #
      # @param [Symbol] method_or_command method or os command name
      #
      def set_command(methods_or_commands)
        @commands ||= []
        methods_or_commands = Array(methods_or_commands) # ensure Array
        methods_or_commands.each do | method_or_command|
          method_or_command = method_or_command.to_s if RUBY_VERSION == '1.8.7'
          @commands << method_or_command
          define_os_command_method(method_or_command) unless methods.include?(method_or_command)
        end
      end

      # @private
      def define_os_command_method(method_or_command)
        eigenclass = class << self; self; end
        eigenclass.send(:define_method, method_or_command) do | *args|
          command = args.dup.unshift(method_or_command)
          Puppet::Util::Execution.execute(command)
        end
      end

      #
      # retuns the string needed to start the creation of an sql type
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    on_create do
      #     "create user #{self[:name]}"
      #    end
      #
      # @param [Method] block The code to be run on creating  a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      #
      def on_create(&block)
        define_method(:on_create, &block) if block
      end

      #
      # retuns the string command needed to remove the specified type
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    on_destroy do
      #     "drop user #{self[:name]}"
      #    end
      #
      # @param [Method] block The code to be run on destroying  a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      #
      def on_destroy(&block)
        define_method(:on_destroy, &block) if block
      end

      #
      # retuns the string command needed to alter an sql type
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    on_modify do
      #     "alter user #{self[:name]}"
      #    end
      #
      # @param [Method] block The code to be run on modifying  a resource. Although the code
      #                 customary returns just a string that is appended to the command, it can do
      #                 anything that is deemed nesceccary.
      #
      def on_modify(&block)
        define_method(:on_modify, &block) if block
      end

      #
      # The code in the block is called to fetch all information of all available resources on the system.
      # Although not strictly necessary, it is a convention the return an Array of Hashes
      #
      # @example
      #  newtype(:oracle_user) do
      #
      #    to_get_raw_resourced do
      #     TODO: Fill in
      #    end
      #
      # @param [Method] block The code to be run to fetch the raw resource information from the system.
      #
      def to_get_raw_resources(&block)
        eigenclass = class << self; self; end
        eigenclass.send(:define_method, :get_raw_resources, &block)
      end
    end
  end
end
