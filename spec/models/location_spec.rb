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

require 'spec_helper'

describe Location do
  pending "add some examples to (or delete) #{__FILE__}"
end
