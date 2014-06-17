require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'utils/oracle_access'

module Puppet
  newtype(:oracle_service) do
    include EasyType
    include ::Utils::OracleAccess

    desc %q{
      This resource allows you to manage a service in an Oracle database.
    }

    ensurable

    set_command(:sql)


    to_get_raw_resources do
      sql "select name from dba_services"
    end

    on_create do | command_builder |
      "exec dbms_service.create_service('#{name}', '#{name}'); dbms_service.start_service('#{name}')"
    end

    on_modify do | command_builder |
      fail "It shouldn't be possible to modify a service"
    end

    on_destroy do | command_builder |
      "exec dbms_service.stop_service('#{name}'); dbms_service.delete_service('#{name}')"
    end

    parameter :name

  end
end
