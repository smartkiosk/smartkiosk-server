class Provider < ActiveRecord::Base
  include Redis::Objects::RMap

  has_rmap({:id => lambda{|x| x.to_s}}, :title)
  has_paper_trail

  mount_uploader :icon, IconUploader

  after_save do
    TerminalProfile.invalidate_all_cached_providers!
  end

  after_destroy do
    TerminalProfile.invalidate_all_cached_providers!
  end

  #
  # RELATIONS
  #
  belongs_to :provider_profile
  belongs_to :provider_group
  belongs_to :provider_receipt_template
  has_many   :provider_gateways
  has_many   :gateways, :through => :provider_gateways
  has_many   :payments, :order => 'id DESC'
  has_many   :commissions, :through => :provider_profile
  has_many   :limits, :through => :provider_profile
  has_many   :provider_fields, :dependent => :destroy, :order => :priority
  has_many   :terminal_profile_providers, :dependent => :destroy, :order => :priority
  has_many   :terminal_profile_promotions, :dependent => :destroy, :order => :priority

  accepts_nested_attributes_for :provider_gateways, :allow_destroy => true
  accepts_nested_attributes_for :provider_fields, :allow_destroy => true

  scope :gateway_ids_eq, lambda{|x| includes(:gateways).where(:gateways => {:id => x})}
  search_method :gateway_ids_eq

  scope :after, lambda{|x|
    x.blank? ? scoped
             : where(arel_table[:updated_at].gt x)
  }

  #
  # VALIDATIONS
  #
  validates :provider_profile, :presence => true
  validates :provider_group, :presence => true
  validates :keyword, :presence => true
  validates :keyword, :uniqueness => true

  #
  # METHODS
  #
  def fields_dump
    provider_fields.as_json(:only => [:keyword, :title, :kind, :mask, :values, :priority, :regexp, :groupping])
  end
end
