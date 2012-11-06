if Agency.count.zero?
  if Rails.env == "production"
    addr = "http://isis.herokuapp.com"
  else
    addr = "http://localhost:3001"
  end

  Agency.create!(name: "Imperial Secret Intelligence of Sirius", address: addr).register
  Agency.fetch_remote_agencies
end
