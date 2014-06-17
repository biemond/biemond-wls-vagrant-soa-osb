newproperty(:version) do
  include EasyType
  include EasyType::Mungers::Upcase
  desc "The version to use to create the database schema"

  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('ROLE').upcase
  end

end
