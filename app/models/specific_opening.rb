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
#  user_role      :string(255)
#

class SpecificOpening < ActiveRecord::Base
  attr_accessible :appointment_id, :opening_id, :scheduled_for, :user_id, :opening_status, :status, :user_role
  belongs_to :user
  belongs_to :appointment
  belongs_to :opening
  has_many :confirmations
  
  scope :after, ->(time) { where("scheduled_for >= ?", time) }
  scope :before, ->(time) { where("scheduled_for <= ?", time) }
  scope :available, where(status: 'available')
  scope :today, after(Time.current.utc.beginning_of_day).before(Time.current.utc.end_of_day)
  scope :tomorrow, after(Time.current.utc.beginning_of_day + 1.day).before(Time.current.utc.end_of_day + 1.day)

  STATUSES = ['available', 'requested_confirmation', 'confirmed', 'canceled']

  
  # Concept of still_on? should only exist for a tutees.  For students they need to
  def still_on?
    if user.role == 'tutee'
      (status == 'confirmed' || status == 'requested_confirmation') && !canceled?
    else 
      puts 'No Op.  Concept only exists for tutees.'
    end
  end

  def canceled?
    (confirmations.last.try(:confirmed) == false)
  end

  def confirmed?
    return true if status == 'confirmed'
    false
  end

  

  def cancel
    self.update_attributes(status: 'canceled')
  end

  def confirm
    self.update_attributes(status: 'confirmed')
    Confirmation.create(specific_opening_id: self.id, user_id: self.user.id, confirmed: true)
  end

  

  def scheduled_for_to_text(user_role)
    self[:scheduled_for].in_time_zone(user.time_zone).strftime("%l:%M %p on %A beginning")
  end
end
