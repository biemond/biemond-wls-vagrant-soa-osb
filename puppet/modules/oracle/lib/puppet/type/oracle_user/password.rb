newparam(:password) do
  include EasyType

  desc "The user's password"
  defaultto 'password'

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('PASSWORD')
  end

  on_apply do | command_builder|
    "identified by #{resource[:password]}"
  end

end
