newproperty(:size) do
  include EasyType
  include EasyType::Mungers::Size

  desc "The size of the tablespace"
  defaultto "500M"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('BYTES').to_i
  end


  on_apply do | command_builder|
    if resource[:datafile]
      "size #{resource[:size]}"
    else
      "datafile size #{resource[:size]}"
    end
  end

end
