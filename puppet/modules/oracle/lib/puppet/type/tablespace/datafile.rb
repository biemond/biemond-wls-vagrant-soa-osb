newproperty(:datafile) do
  include EasyType
  desc "The name of the datafile"

  on_apply do
    "datafile '#{resource[:datafile]}'"
  end

  to_translate_to_resource do | raw_resource|
    File.basename(raw_resource.column_data('FILE_NAME'))
  end

end
