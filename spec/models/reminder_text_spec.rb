# == Schema Information
#
# Table name: reminder_texts
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  time           :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  type           :string(255)
#

require 'spec_helper'

describe ReminderText do
  pending "add some examples to (or delete) #{__FILE__}"
end
