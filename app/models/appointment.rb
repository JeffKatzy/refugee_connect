# == Schema Information
#
# Table name: appointments
#
#  id            :integer          not null, primary key
#  status        :string(255)
#  start_page    :integer
#  finish_page   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  scheduled_for :text
#  user_id       :integer
#  began_at      :datetime
#  ended_at      :datetime
#

class Appointment < ActiveRecord::Base
  attr_accessible :finish_page, :start_page, :status, :scheduled_for, :user_id, :began_at, :ended_at

  scope :after, ->(time) { where("scheduled_for > ?", time) }
  scope :before, ->(time) { where("scheduled_for < ?", time) }
  scope :this_week, after(Time.now.beginning_of_week).before(Time.now.end_of_week)
  belongs_to :user
  has_many :call_to_users

  def start_call
  	self.call_to_users.build(tutor_id: user.id, tutee_id: user.id)
  	self.call_to_users.last.start_call
  end
end
