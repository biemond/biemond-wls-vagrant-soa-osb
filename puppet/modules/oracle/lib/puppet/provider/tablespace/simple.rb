require 'utils/oracle_access'
require 'easy_type'

Puppet::Type.type(:tablespace).provide(:simple) do
	include EasyType::Provider
	include ::Utils::OracleAccess

  desc "Manage an Oracle Tablespace in an Oracle Database via regular SQL"

  mk_resource_methods

end

