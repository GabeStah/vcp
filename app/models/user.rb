class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:bnet]
  before_create :create_secret_key
  has_many :assignments
  has_many :characters
  has_many :roles, through: :assignments

  validates :battle_tag,
            presence: true,
            length: { maximum: 50 }

  def self.from_omniauth(auth)
    logger.info 'BATTLE_NET_AUTH: User#from_omniauth'
    new_user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.battle_tag = auth['info']['battletag']
    end
    # worker update
    BattleNetWorker.perform_async(access_token: auth['credentials']['token'], type: 'characters', user_id: new_user.id)
    new_user
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  # def self.find_for_oauth(auth, signed_in_resource = nil)
  #
  #   # Get the identity and user if they exist
  #   identity = Identity.find_for_oauth(auth)
  #
  #   # If a signed_in_resource is provided it always overrides the existing user
  #   # to prevent the identity being locked with accidentally created accounts.
  #   # Note that this may leave zombie accounts (with no associated identity) which
  #   # can be cleaned up at a later date.
  #   user = signed_in_resource ? signed_in_resource : identity.user
  #
  #   # Create the user if needed
  #   if user.nil?
  #
  #     # Get the existing user by email if the provider gives us a verified email.
  #     # If no verified email was provided we assign a temporary email and ask the
  #     # user to verify it on the next step via UsersController.finish_signup
  #     email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
  #     email = auth.info.email if email_is_verified
  #     user = User.where(:email => email).first if email
  #
  #     # Create the user if it's a new registration
  #     if user.nil?
  #       user = User.new(
  #         name: auth.extra.raw_info.name,
  #         #username: auth.info.nickname || auth.uid,
  #         email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
  #         password: Devise.friendly_token[0,20]
  #       )
  #       user.skip_confirmation!
  #       user.save!
  #     end
  #   end
  #
  #   # Associate the identity with the user if needed
  #   if identity.user != user
  #     identity.user = user
  #     identity.save!
  #   end
  #   user
  # end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def create_secret_key
    self.secret_key = Digest::SHA2.hexdigest(battle_tag)
  end
end