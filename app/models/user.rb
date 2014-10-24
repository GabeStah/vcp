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
  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 100}

  def self.from_omniauth(auth)
    logger.info 'BATTLE_NET_AUTH: User#from_omniauth'
    # Initialize only
    new_user = where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.battle_tag = auth['info']['battletag']
      user.name = auth['info']['battletag'].split('#').first
      user.password = Devise.friendly_token[0,20]
      user.provider = auth.provider
      user.uid = auth.uid
    end
    # If new, check for role assignment from settings
    if new_user.new_record?
      # Add roles if necessary
      Settings.roles.each do |role, tags|
        if tags
          tags.each do |tag|
            if tag == new_user.battle_tag
              role_record = Role.find_by(name: role.to_s.to_sym)
              new_user.roles << role_record if role_record
            end
          end
        end
      end
    end
    # Now save record
    if new_user.save
      # worker update
      BattleNetWorker.perform_async(
        access_token: auth['credentials']['token'],
        type: 'characters',
        user_id: new_user.id
      )
    end
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

  def has_role_from_settings?(role)
    # Add roles if necessary
    Settings.roles.each do |setting_role, tags|
      if tags
        tags.each do |tag|
          if tag.downcase == self.battle_tag.downcase
            role_record = Role.find_by(name: setting_role.to_s.to_sym)
            return true if role_record && role_record == role
          end
        end
      end
    end
    false
  end

  def create_secret_key
    self.secret_key = Digest::SHA2.hexdigest(battle_tag)
  end
end