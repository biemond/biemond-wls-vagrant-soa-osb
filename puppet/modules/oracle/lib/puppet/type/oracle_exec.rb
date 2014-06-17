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
  newtype(:oracle_exec) do
    include EasyType
    include ::Utils::OracleAccess

    desc "This resource allows you to execute any sql command in a database"



   def self.title_patterns
      # require 'ruby-debug'
      # debugger
      [
        [
          /^((.*))$/,
          [
            [ :statement      , nil     ],
            [ :name           , nil      ],
          ]
        ],
      ]
    end

    parameter :name
    parameter :logoutput
    parameter :password
    parameter :username
    property  :statement

  end


end



