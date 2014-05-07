newproperty(:password) do
  include EasyType
  desc "The password"

  to_translate_to_resource do | raw_resource|
    ''
  end

 on_apply do
    "identified by #{value}"
  end

end

