class IconUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process :resize_to_limit => [200, 200]

  version :thumb do
    process :resize_to_limit => [30, 30]
  end
end
