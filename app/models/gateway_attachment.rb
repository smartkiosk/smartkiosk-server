class GatewayAttachment < ActiveRecord::Base

  #
  # RELATIONS
  #
  belongs_to :gateway

  mount_uploader :value, FileUploader
end
