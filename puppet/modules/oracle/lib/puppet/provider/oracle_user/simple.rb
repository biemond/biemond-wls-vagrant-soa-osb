require 'easy_type'
require 'utils/oracle_access'

Puppet::Type.type(:oracle_user).provide(:simple) do
	include EasyType::Provider
	include ::Utils::OracleAccess

  desc "Manage Oracle users in an Oracle Database via regular SQL"


  mk_resource_methods

end

