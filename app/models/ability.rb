class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # for guest
    @user.roles.each { |role| send(role.name) }

    if @user.roles.size == 0
      can :read, [Character, Raid, Standing, User]
    end
  end

  def manager
    can :manage, :all
  end

  def admin
    manager
    can :manage, :all
  end
end
