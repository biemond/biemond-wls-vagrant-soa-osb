require 'tempfile'
require 'fileutils'
require 'utils/ora_daemon'

module Utils
  module OracleAccess

    ORATAB = "/etc/oratab"

    def self.included(parent)
      parent.extend(OracleAccess)
    end

    ##
    #
    # Use this function to execute Oracle statements
    #
    # @param command [String] this is the commands to be given
    #
    #
    def sql( command, parameters = {})
      sid = parameters.fetch(:sid) {
        oratab.first[:sid] # For now if no sid is given always use the first one
      }
      username = parameters.fetch(:username) { 'sysdba'}
      password = parameters[:password] # nil is allowed

      Puppet.info "Executing: #{command} on database #{sid}"
      csv_string = execute_sql(command, :sid => sid, :username => username, :password => password)
      convert_csv_data_to_hash(csv_string, [], :converters=> lambda {|f| f ? f.strip : nil})
    end


    private

    def oratab
      values = []
      fail "/etc/oratab not found. Probably Oracle not installed" unless File.exists?(ORATAB)
      File.open(ORATAB) do | oratab|
        oratab.each_line do | line|
          content = [:sid, :home, :start].zip(line.split(':'))
          values << Hash[content] unless comment?(line)
        end
      end
      values
    end

    def execute_sql(command, parameters)
      db_sid = parameters.fetch(:sid) { raise ArgumentError, "No sid specified"}
      username = parameters.fetch(:username) { 'sysdba'}
      password = parameters[:password] # null allowd
      daemon = OraDaemon.run('oracle', db_sid, username, password)
      outFile = Tempfile.new([ 'output', '.csv' ])
      outFile.close
      FileUtils.chmod(0777, outFile.path)
      daemon.execute_sql_command(command, outFile.path)
      File.read(outFile.path)
    end

    def comment?(line)
      line.start_with?('#') || line.start_with?("\n")
    end

  end
end