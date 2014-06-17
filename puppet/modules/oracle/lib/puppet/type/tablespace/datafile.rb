newproperty(:datafile) do
  include EasyType
  desc "The name of the datafile"

  to_translate_to_resource do | raw_resource|
    File.basename(raw_resource.column_data('FILE_NAME'))
  end

  on_apply do | command_builder|
    "datafile '#{resource[:datafile]}'"
  end

end
