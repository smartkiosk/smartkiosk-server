class DPS::Operator < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'CyberplatOperators'
  self.primary_key = 'CyberplatOperatorID'

  has_one :inner_provider, :class_name => '::Provider', :foreign_key => 'foreign_id'

  def build_inner_provider!
    provider = Provider.find_by_id(self.CyberplatOperatorID)

    return provider unless provider.blank?

    provider = Provider.new(
      :title      => self.Name,
      :keyword    => "DPS.#{self.CyberplatOperatorID}",
      :provider_profile_id => ProviderProfile.find_by_title('DPS').id,
      :provider_group_id => ProviderGroup.find_by_title('DPS').id
    )
    provider.id = self.CyberplatOperatorID
    provider.save!

    provider
  end

  def self.import_all!
    all.each{|o| o.build_inner_provider!}
    true
  end
end