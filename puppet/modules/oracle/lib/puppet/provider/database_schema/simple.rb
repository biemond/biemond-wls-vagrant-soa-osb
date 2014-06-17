require 'utils/oracle_access'
require 'easy_type'

Puppet::Type.type(:database_schema).provide(:simple) do
  include EasyType::Provider
  include ::Utils::OracleAccess

  desc "Manage Oracle database schema;s via regular SQL"

  mk_resource_methods

end

