# == Schema Information
#
# Table name: call_to_users
#
#  id             :integer          not null, primary key
#  tutor_id       :integer
#  tutee_id       :integer
#  begin_time     :datetime
#  end_time       :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  appointment_id :integer
#

require 'spec_helper'

describe CallToUser do
  describe '#start_call' do
  	
  end
end
