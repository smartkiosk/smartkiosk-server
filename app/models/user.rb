class User < ActiveRecord::Base
  
  has_paper_trail

  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  #
  # RELATIONS
  #
  has_many :user_roles
  has_many :roles, :through => :user_roles

  accepts_nested_attributes_for :user_roles, :allow_destroy => true

  #
  # VALIDATIONS
  #
  validates :full_name, :presence => true

  #
  # METHODS
  #
  def role?(role)
    return true if root
    return roles.map{|x| x.keyword}.include? role.to_s
  end

  def priveleged?(role, action)
    return true if root
    ur = user_roles.includes(:role).find{|x| x.role.keyword == role.to_s}
    ur.blank? ? false : ur.priveleged?(action)
  end

  def title
    email
  end
end
