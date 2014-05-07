require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'utils/oracle_access'

module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the SqlResource
  #
  newtype(:role) do
    include EasyType
    include ::Utils::OracleAccess

    desc "This resource allows you to manage a role in an Oracle database."

    set_command(:sql)

    ensurable

    to_get_raw_resources do
      sql "select * from dba_roles"
    end

    on_create do
    	"create role #{self[:name]}"
    end

    on_modify do
      "alter role#{self[:name]}"
    end

    on_destroy do
      "drop role#{self[:name]}"
    end

    parameter :name
    property  :password


  end
end


