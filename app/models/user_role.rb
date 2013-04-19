class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  serialize :priveleges, JSON

  validates :role, :presence => true

  def method_missing(method, *args)
    method = method.to_s

    if method.starts_with? 'can_'
      role_keyword = method[method.index('_')+1..method.rindex('_')-1]
      privelege    = method[method.rindex('_')+1..-1]

      self.priveleges = [] unless self.priveleges.is_a?(Array)

      if method.ends_with? '='
        privelege = privelege[0..-2]

        if role && role.keyword == role_keyword
          if args[0] && args[0] != 'false'
            self.priveleges = (self.priveleges + [privelege]).uniq
          else
            self.priveleges = self.priveleges.select{|x| x != privelege}
          end
        end
      else
        return false if !role || role.keyword != role_keyword
        self.priveleges.include?(privelege)
      end
    else
      super(method.to_sym, *args)
    end
  end

  def respond_to?(method, *args)
    return true if method.to_s.starts_with? 'can_'
    super
  end

  def priveleged?(privelege)
    priveleges.include?(privelege.to_s)
  end
end