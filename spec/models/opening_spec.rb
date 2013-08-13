# == Schema Information
#
# Table name: openings
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  time_open  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  day_open   :string(255)
#

require 'spec_helper'

describe Opening do
  pending "add some examples to (or delete) #{__FILE__}"
end
