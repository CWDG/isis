require 'bcrypt'

class Agent < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :code_name, :email, :first_name, :github, :last_name, :password, :password_confirmation

  validates :code_name, presence: true, uniqueness: true, length: {in: 3..20}
  validates :email, presence: true, uniqueness: true, length: {minimum: 6}
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :github, presence: true, allow_blank: false
  validates :password, presence: true, confirmation: true, length: {minimum: 6}, on: :create
  validates :password_hash, presence: true, on: :save

  before_save :encrypt_password


  private

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
