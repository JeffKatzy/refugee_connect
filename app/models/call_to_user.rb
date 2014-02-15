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
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id

  BASE_URL =  "http://agile-mesa-7894.herokuapp.com/"
  @@client = Twilio::REST::Client.new(ENV['TW_SID'], ENV['TW_TOK'])
  @@account = @@client.account

  def start_call
  	@call = @@account.calls.create({:from => '+12673172085', :to => self.tutor.cell_number, :url => BASE_URL + "appointments/complete/#{self.appointment.id}.xml", :status_callback => BASE_URL + "appointments/askpagenumber/#{self.appointment.id}.xml"})
  	puts @call
  	self.begin_time = Time.now.in_time_zone('Eastern Time (US & Canada)') 
  	self.save
  end
end


