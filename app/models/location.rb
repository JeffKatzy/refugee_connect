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
#

class Location < ActiveRecord::Base
  attr_accessible :address, :latitude, :longitude, :user_id
  belongs_to :user
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  def formatted_address
  	geo = Geocoder.search(self.address)
    geo.first.data["formatted_address"]
  end
end
