# == Schema Information
#
# Table name: specific_openings
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  opening_id     :integer
#  appointment_id :integer
#  scheduled_for  :datetime
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe SpecificOpening do
  pending "add some examples to (or delete) #{__FILE__}"
end
