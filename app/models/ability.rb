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
      guest
    end
  end

  def guest
    can :ghost, [User] if Rails.env.development?
    can :read, [Character, Raid, Standing, User]
  end

  def moderator
    guest
    can :manage, [Character, Guild, Participation, Raid]
  end

  def admin
    moderator
    can :manage, :all
  end
end
