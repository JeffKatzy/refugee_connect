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

class CallToUser < ActiveRecord::Base
  attr_accessible :begin_time, :end_time, :tutee_id, :tutor_id
  belongs_to :appointment

  BASE_URL =  "http://radiant-autumn-9123.herokuapp.com/"

  def start_call
	@client = Twilio::REST::Client.new(ENV['TW_SID'], ENV['TW_TOK'])
  	@account = @client.account
	#Find the associated student and refugee
	tutor = Tutor.find(tutor_id) 
	@call = @account.calls.create({:from => '+12673172085', :to => '+1' + tutor.cell_number )
	puts @call
	self.save
  end
end
