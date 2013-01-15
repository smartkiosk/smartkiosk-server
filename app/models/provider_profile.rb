class ProviderProfile < ActiveRecord::Base
  include Redis::Objects::RMap

  has_rmap({:id => lambda{|x| x.to_s}}, :title)

  has_many :providers
  has_many :limits
  has_many :commissions
end
