class Ability
  include CanCan::Ability

  def initialize(user)
    if user.root
      can :manage, :all
    else
      user.user_roles.each do |ur|
        model = ur.role.modelize 

        can :read, model if ur.priveleged?(:read)
        can [:new, :create], model if ur.priveleged?(:create)
        can [:edit, :update], model if ur.priveleged?(:edit)
        can :destroy, model if ur.priveleged?(:destroy)
      end

      Terminal::ORDERS.each do |order|
        can order, Terminal if user.priveleged?(:terminals, order)
      end
    end

    cannot :destroy, User do |x|
      x == user
    end

    cannot :destroy, ProviderReceiptTemplate do |x|
      x.system?
    end
  end
end