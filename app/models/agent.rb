require 'bcrypt'
require 'rest-client'

class Agent < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :code_name, :email, :first_name, :github, :last_name, :password, :password_confirmation,
                  :registered_id

  validates :code_name, presence: true, uniqueness: true, length: {in: 3..20}
  validates :email, presence: true, uniqueness: true, length: {minimum: 6}
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :github, presence: true, allow_blank: false
  validates :password, presence: true, confirmation: true, length: {minimum: 6}, on: :create
  validates :password_hash, presence: true, on: :save

  before_save :encrypt_password
  after_create :register

  def self.authenticate(code_name, password)
    agent = Agent.find_by_code_name(code_name)
    if agent && agent.password_hash == BCrypt::Engine.hash_secret(password, agent.password_salt)
      agent
    else
      nil
    end
  end


  private

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end


  if Rails.env == "production"
    AGENT_REGISTRATION_URL = "http://the-great-game.herokuapp.com/agents.json"
  else
    AGENT_REGISTRATION_URL = "http://localhost:3000/agents.json"
  end

  def register
    attrs = {
      agency_id: Agency.registered_id,
      code_name: code_name,
      email: email,
      github: github
    }

    begin
      res = RestClient.post(AGENT_REGISTRATION_URL, agent: attrs)
      self.registered_id = JSON.parse(res)["id"]
      save!
    rescue Exception => ex
      Rails.logger.fatal "Error registering new agent with master server! #{ex.message}"
    end
  end

end
