class ProviderField < ActiveRecord::Base
  belongs_to :provider

  validates :title, :presence => true
  validates :kind, :presence => true
  validates :values, :presence => true, :if => lambda{|x| x.kind == 'select'}
end
