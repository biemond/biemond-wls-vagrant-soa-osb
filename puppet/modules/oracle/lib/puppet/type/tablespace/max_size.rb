# TODO: Check values
newproperty(:max_size) do
  include EasyType
  include EasyType::Mungers::Size

  desc "maximum size for autoextending"

  # TODO: Check why it doesn't retirn the right values
  to_translate_to_resource do | raw_resource|
    raw_resource.column_data('MAX_SIZE').to_f.to_i
  end

  on_apply do
  	"maxsize #{should}"
  end

end
