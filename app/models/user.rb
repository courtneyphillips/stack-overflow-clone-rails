class User < ActiveRecord::Base
  has_many :questions
  has_many :answers
  has_many :comments

  after_create :send_confirm_email

  attr_accessor :password
  validates_presence_of :password
  validates_presence_of :name
  validates_confirmation_of :password
  before_save :encrypt_password

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def self.authenticate(email, password)
    user = User.where(email: email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def send_confirm_email
    UserMailer.signup_confirmation(self).deliver_now
  end

end
