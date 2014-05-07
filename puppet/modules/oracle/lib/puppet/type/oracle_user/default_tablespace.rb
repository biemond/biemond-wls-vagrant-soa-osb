newproperty(:default_tablespace) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The user's default tablespace"
  defaultto 'USERS'

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('DEFAULT_TABLESPACE').upcase
  end

  on_apply do
    "default tablespace #{resource[:default_tablespace]}"
  end

end
