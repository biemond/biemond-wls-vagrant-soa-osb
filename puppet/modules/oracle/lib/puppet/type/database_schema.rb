require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'utils/oracle_access'

module Puppet

  #
  # database_schema{ 'pif':
  # }
  #
  #
  #
  #

  newtype(:database_schema) do
    include EasyType
    include ::Utils::OracleAccess

    desc "This resource allows you to manage a schema within an Oracle database"

    set_command(:sql)

    ensurable

    on_create do | command_builder |
      # TODO
    end

    on_modify do | command_builder |
      # TODO
    end

    on_destroy do | command_builder |
      # TODO
    end

    to_get_raw_resources do
      get_schema_version
    end

    parameter :name
    parameter :password
    property  :version
    property  :source

    private

    def get_schema_version
      statement = "select * from schema_versie where systeem = '$system' and versie = '$version' and module = '$module';"
      sql statement, :username => username, :password => password
    end

  end
end

