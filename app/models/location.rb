# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  address    :string(255)
#  latitude   :float
#  longitude  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  country    :string(255)
#

class Location < ActiveRecord::Base
  attr_accessible :address, :latitude, :longitude, :user_id, :city, :state, :zip
  belongs_to :user
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  def geocoder_address_info
  	begin
  		geo = Geocoder.search(self.address)
    	geo.first
    rescue
		  nil
    end
  end

end
