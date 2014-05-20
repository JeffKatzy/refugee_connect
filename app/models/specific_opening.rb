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
  scope :after, ->(time) { where("scheduled_for >= ?", time) }
  scope :before, ->(time) { where("scheduled_for <= ?", time) }

  def upcoming?
  	Time.current + 1.hour + 30.minutes > self.scheduled_for
  end

  def match_from_related_users
    partners = self.user.appointment_partners
    if partners.present?
      opening = partners.map(&:specific_openings).flatten.detect do |s_o|
        s_o.scheduled_for == self.scheduled_for && 
          s_o.status == 'confirmed'
      end
    end
  end

  def match_from_unrelated_users
    tutor_opening = SpecificOpening.after(self.scheduled_for - 1.minute).
      before(self.scheduled_for + 1.minute).where(user_role: self.user.is_tutor? ? 'tutee' : 'tutor', 
      status: 'confirmed').first
  end
end
