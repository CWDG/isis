require 'rest-client'

class Agency < ActiveRecord::Base
  attr_accessible :abbr, :address, :name, :registered_id

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true

  before_save :create_abbr

  if Rails.env == "production"
    AGENCY_URL = "http://the-great-game.herokuapp.com/agencies.json"
  else
    AGENCY_URL = "http://localhost:3000/agencies.json"
  end

  def register
    begin
      res = RestClient.post(AGENCY_URL, agency: { name: name, address: address })
      self.registered_id = JSON.parse(res)['id']
      save!

    rescue Exception => ex
      Rails.logger.error "Could not register Agency with remote server. #{ex.message}"
    end
  end

  def self.fetch_remote_agencies
    begin
      res = RestClient.get(AGENCY_URL)
      JSON.parse(res).each do |agency|
        if Agency.find_by_registered_id(agency['id']).nil?
          Agency.create!(name: agency["name"], address: agency["address"], registered_id: agency["id"])
        end
      end
    rescue Exception => ex
      Rails.logger.error "Could not fetch remote Agencies. #{ex.message}"
    end
  end

  def self.registered_id
    Agency.first.registered_id
  end
  def self.full_name
    Agency.first.name
  end
  def self.abbr
    Agency.first.abbr
  end
  def self.address
    Agency.first.address
  end


  private

  def create_abbr
    if name.present? && name_changed? && abbr.blank?
      self.abbr = name.split(' ').map(&:first).reject{|l| l =~ /[a-z]/ }.join('')
    end
  end


end
