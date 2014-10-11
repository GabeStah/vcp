class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  before_create :create_secret_key
  has_many :assignments
  has_many :characters
  has_many :roles, through: :assignments

  validates :name,
            presence: true,
            length: { maximum: 50 }

  normalize_attribute :name, :with => :squish
  normalize_attribute :email

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def create_secret_key
    self.secret_key = Digest::SHA2.hexdigest(email)
  end
end