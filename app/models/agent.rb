class Agent < ActiveRecord::Base
  include Redis::Objects::RMap

  has_rmap({:id => lambda{|x| x.to_s}}, :title)
  has_paper_trail

  #
  # RELATIONS
  #
  scope :root, where(:agent_id => nil)

  has_many :terminals
  has_many :agents
  has_many :commissions
  has_many :payments, :order => 'id DESC'

  belongs_to :agent

  #
  # VALIDATIONS
  #
  validates :title, :presence => true

end
