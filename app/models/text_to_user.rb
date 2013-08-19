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
#

require 'builder'

class TextToUser < ActiveRecord::Base
  attr_accessible :body, :time, :user_id
  belongs_to :user
  belongs_to :appointment

  def self.deliver(user, body)
  	@client = Twilio::REST::Client.new(ENV['TW_SID'], ENV['TW_TOK'])
  	@account = @client.account
  	@message = @account.sms.messages.create(:from => '+12673172085', :to => user.cell_number, :body => body)
  	TextToUser.create(body: body, user_id: user.id, time: Time.now.in_time_zone('Eastern Time (US & Canada)'))
  	puts @message 
  end
end
