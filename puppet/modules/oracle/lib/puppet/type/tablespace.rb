require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'utils/oracle_access'

module Puppet
  newtype(:tablespace) do
    include EasyType
    include ::Utils::OracleAccess

    desc "This resource allows you to manage an Oracle tablespace."

    set_command(:sql)

    ensurable

    on_create do
      "create #{ts_type} tablespace \"#{name}\""
    end

    on_modify do
      "alter tablespace \"#{name}\""
    end

    on_destroy do
      "drop tablespace \"#{name}\" including contents and datafiles"
    end

    to_get_raw_resources do
      sql %q{select 
        t.tablespace_name,
        logging,
        extent_management,
        segment_space_management,
        bigfile,
        file_name,
        to_char(increment_by, '9999999999999999999') "INCREMENT_BY",
        to_char(block_size, '9999999999999999999') "BLOCK_SIZE",
        autoextensible,
        bytes,
        to_char(maxbytes, '9999999999999999999') "MAX_SIZE"
      from 
        dba_tablespaces t, 
        dba_data_files f 
      where
        t.tablespace_name = f.tablespace_name
      }
    end

    parameter :name
    property  :logging
    property  :datafile
    property  :size
    group(:autoextend_info) do
      property :autoextend
      property :next
      property :max_size
    end
    property :extent_management
    property :segment_space_management
    property :bigfile


    def ts_type
      if self['bigfile'] == :yes
        'bigfile'
      else
        'smallfile'
      end
    end


  end
end
