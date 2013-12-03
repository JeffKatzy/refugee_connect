# == Schema Information
#
# Table name: matches
#
#  id         :integer          not null, primary key
#  tutor_id   :integer
#  tutee_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_time :datetime
#

class Match < ActiveRecord::Base
  attr_accessible :tutee_id, :tutor_id, :match_time

  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id
  belongs_to :match_partner_of_tutor, class_name: 'User', foreign_key: :tutee_id
  belongs_to :match_partner_of_tutee, class_name: 'User', foreign_key: :tutor_id

  scope :after, ->(time) { where("match_time >= ?", time) }
  scope :before, ->(time) { where("match_time <= ?", time) }
  scope :this_week, after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week)

  

  def self.build_all_matches_for(user, datetime)
  	if user.availability_manager.available_before?(datetime)
  		if user.appointments.present? || user.matches.present?
  			Match.build_matches_for(user, user.appointment_partners, datetime) if user.appointment_partners.present?
  			Match.build_matches_for(user, user.match_partners, datetime) if (user.appointment_partners.empty? && user.match_partners.present?)
  			Match.build_matches_for(user, User.scoped, datetime) if (user.match_partners.empty? && user.appointment_partners.empty?)
  		else
  			Match.build_matches_for(user, User.scoped, datetime)
  		end
    end
  end

  def self.build_matches_for(primary_user, users, datetime)
  	if primary_user.role == 'tutor'
  		potential_users = users.active.tutees.select { |u| u.availability_manager.available_before?(datetime) }
  	else
  		potential_users = users.active.tutors.select { |u| u.availability_manager.available_before?(datetime) }
  	end
  	potential_users.each do |opp_user|
  		Match.match_create(primary_user, opp_user, datetime) 
  	end
  end
  
  def self.match_create(first_user, second_user, datetime)
    first_user.availability_manager.remaining_occurrences(datetime).each do |start_time|
      end_time = start_time + 1.hour
      if second_user.availability_manager.schedule.occurring_between?(start_time, end_time)
      	match = Match.new(match_time: start_time)
      	match.assign_user_role(first_user.id)
      	match.assign_user_role(second_user.id)
      end
    end
  end

  def assign_user_role(user_id)
    user = User.find(user_id)
    if user.is_tutor?
      self.tutor = user
    else 
      self.tutee = user
    end
    self.save
  end
end
