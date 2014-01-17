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
  attr_accessible :tutee_id, :tutor_id, :match_time, :available

  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id
  belongs_to :match_partner_of_tutor, class_name: 'User', foreign_key: :tutee_id
  belongs_to :match_partner_of_tutee, class_name: 'User', foreign_key: :tutor_id
  scope :available, where(available: true)
  has_one :appointment
  after_create :make_available
  validate :too_many_apts

  scope :after, ->(time) { where("match_time >= ?", time) }
  scope :before, ->(time) { where("match_time <= ?", time) }
  scope :this_week, after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week)
  scope :until, ->(time) { after(Time.current.utc).where("match_time <= ?", time) }

  

  def self.build_all_matches_for(user, datetime)
    user.reload
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

  def self.available_until(time)
    available.until(time).select{|m| m.available_users }
  end

  def available_users
    if ( self.tutor.wants_more_appointments_before(self.match_time) && self.tutee.wants_more_appointments_before(self.match_time) )
      true
    else
      false
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
  	second_user_is_match_partner = true if first_user.match_partners.include?(second_user)
    first_user.availability_manager.remaining_occurrences(datetime).each do |start_time|
      end_time = start_time + 1.hour
      if second_user.availability_manager.schedule.occurring_between?(start_time, end_time)
      	next if second_user_is_match_partner && Match.already_a_match(first_user, second_user, start_time) #this 'already' method should be a validation
      	match = Match.new(match_time: start_time)
      	match.assign_user_role(first_user.id)
      	match.assign_user_role(second_user.id)
        
        if match.invalid?
          logger.debug "#{match.errors}"
          next #notice without save
        else 
          match.save
        end
      end
    end
  end
  #note that you may want match create to actually return the created matches

  def self.already_a_match(first_user, second_user, start_time)
  	if first_user.is_tutor?
	  	if Match.where(tutor_id: first_user.id, tutee_id: second_user.id).after(start_time - 5.minutes).before(start_time + 5.minutes).present?
	  		true 
	  	else
	  		false
	  	end
	  else
	  	if Match.where(tutee_id: first_user.id, tutor_id: second_user.id).after(start_time - 5.minutes).before(start_time + 5.minutes).present?
	  		true
	  	else
	  		false
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
  end

  def convert_to_apt
	  apt = self.build_appointment(scheduled_for: self.match_time, 
		  tutor_id: self.tutor.id, 
		  tutee_id: self.tutee.id)
    return apt if apt.invalid?
    self.available = false
	  apt.save
  end

  def make_available
  	self.available = true
  	self.save
  end

  # def self.batch_create(user_id, matches)
  #   matches.each do |match|
  #     matching_user_id = match.first.to_i
  #     matching_time = match.last.to_datetime
  #     apt = Appointment.new(scheduled_for: matching_time)
  #     apt.assign_user_role(matching_user_id)
  #     apt.assign_user_role(user_id.to_i)
  #     apt.status = 'incomplete'
  #     apt.save 
  #   end
  # end

  def too_many_apts
    if (self.tutor.too_many_apts_per_week(self.match_time) || self.tutee.too_many_apts_per_week(self.match_time) )
      errors[:base] << "Both tutor and tutee must want more apppointments."
    end
  end  
end
