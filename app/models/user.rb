class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # before_save { self.email = email.downcase }
  # before_create :create_remember_token
  before_create :create_secret_key
  has_many :assignments
  has_many :characters
  has_many :roles, through: :assignments

  # validates :name,
  #           presence: true,
  #           length: { maximum: 50 }

  # has_secure_password

  normalize_attribute :name, :with => :squish
  normalize_attribute :email

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  # def User.new_remember_token
  #   SecureRandom.urlsafe_base64
  # end
  #
  # def User.digest(token)
  #   Digest::SHA1.hexdigest(token.to_s)
  # end
  #
  # private
  #
  # def create_remember_token
  #   self.remember_token = User.digest(User.new_remember_token)
  # end
  def create_secret_key
    self.secret_key = Digest::SHA2.hexdigest(email)
  end
end