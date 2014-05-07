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

    on_create do
      new_services = current_services << name
      set_services_command(new_services)
    end

    on_modify do
      fail "It shouldn't be possible to modify a service"
    end

    on_destroy do
      new_services = current_services.delete_if {|e| e == name }
      set_services_command(new_services)
    end

    parameter :name

    private

      def set_services_command(services)
        "alter system set service_names = '#{services.join(',')}'"        
      end

      def current_services
        provider.class.instances.map(&:name)
      end

  end
end
