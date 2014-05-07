newproperty(:quotas) do
  include EasyType
  include ::Utils::OracleAccess

  desc "quota's for this user"

  to_translate_to_resource do | raw_resource|
    username = raw_resource.column_data('USERNAME').upcase
    @raw_quotas ||= sql "select * from dba_ts_quotas"
    quota_for(username)
  end

  def validate(value)
    Puppet.Error "resource must be a hash like structure" unless value.class == Hash
  end

  def munge(value)
    return_value = {}
    value.each do | tablespace_name, quota|
      return_value.merge!({ tablespace_name.upcase => quota })
    end
    return_value
  end

  on_apply do | command_builder |
    all_quotas = value.collect do | tablespace, quota|
      "QUOTA #{quota} ON #{tablespace}"
    end
    all_quotas.join(',')
  end

  private

  def self.quota_for(user)
    translate(@raw_quotas.select{|q| q['USERNAME'] == user})
  end

  def self.translate(raw)
    return_value = {}
    raw.each do |raw_line|
      return_value.merge!({ tablespace_name(raw_line) => size(raw_line)})
    end
    return_value
  end

  def self.tablespace_name(raw)
    raw['TABLESPACE_NAME']
  end

  def self.size(raw)
    value = raw['MAX_BYTES']
    if value == '-1'
      'unlimited'
    else
      Integer(value)
    end
  end

end
