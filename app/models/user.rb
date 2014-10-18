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
    BattleNetWorker.perform_async(
      access_token: auth['credentials']['token'],
      type: 'characters',
      user_id: new_user.id
    )
    new_user
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def create_secret_key
    self.secret_key = Digest::SHA2.hexdigest(battle_tag)
  end
end