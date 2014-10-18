class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :history, to: :read
    # Allow sync for owned characters
    can :sync, Character do |character|
      user.characters.include?(character)
    end

    @user = user || User.new # for guest
    @user.roles.each { |role| send(role.name) }

    if @user.roles.size == 0
      can :read, [Character, Raid, Standing, User]
      #can :manage, :all
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
