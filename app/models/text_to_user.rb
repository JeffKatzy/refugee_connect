# == Schema Information
#
# Table name: text_to_users
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  time       :datetime
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  received   :string(255)
#

require 'builder'

class TextToUser < ActiveRecord::Base
  attr_accessible :body, :time, :user_id
  belongs_to :user
  belongs_to :appointment
  BASE_URL =  "http://agile-mesa-7894.herokuapp.com/"

  @@client = Twilio::REST::Client.new(ENV['TW_SID'], ENV['TW_TOK'])
  @@account = @@client.account

  def self.deliver(user, body)
    begin
  	 @text = TextToUser.create(body: body, user_id: user.id, time: Time.now.in_time_zone('Eastern Time (US & Canada)'))
      @message = @@account.sms.messages.create(:from => '+12673172085', :to => user.cell_number, :body => body, :status_callback => BASE_URL + "text_to_users/complete/#{@text.id}.xml")
  	 puts @message 
    rescue
      "Failed in sending to user #{user.name} the message #{body}"
    end
  end
end
