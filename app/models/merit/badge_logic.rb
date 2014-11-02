module BadgeLogic

  def create_badge(*args)
    Merit::Badge.create!(args)
  end

  def create_all

    ### USER ###

    create_badge(
      id: 1,
      name: 'active_account',
      custom_fields: { minutes: 1500 }
    )

    create_badge(
      id: 2,
      name: 'active_account',
      custom_fields: { minutes: 1600 }
    )

    create_badge(
      id: 3,
      name: 'active_account',
      custom_fields: { minutes: 1700 }
    )

  end

  class AccountActivity

    def initialize(*args)
      self.user = args[:user]
    end

    def active_account()

    end

    def user
      @user
    end

    def user=(user)
      @user = user
    end
  end

  class User

    def active_account(user, *custom_fields)

    end

  end

end