class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  before_create :create_remember_token
  before_create :create_secret_key
  has_many :characters

  validates :email,
            presence: true,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
            uniqueness: { case_sensitive: false }
  validates :name,
            presence: true,
            length: { maximum: 50 }
  validates :password,
            length: { minimum: 6 }

  has_secure_password

  normalize_attribute :name, :with => :squish
  normalize_attribute :email

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

  def create_remember_token
    self.remember_token = User.digest(User.new_remember_token)
  end
  def create_secret_key
    self.secret_key = Digest::SHA2.hexdigest(email)
  end
end