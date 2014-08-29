class SpecificOpeningMatcher
	attr_accessor :specific_openings

	def initialize(specific_openings)
		@specific_openings = specific_openings
	end

	def matches_and_creates_apts
  	specific_openings.each do |s_o|
  		if !upcoming?(s_o)
        match_opening = match_from_related_users(s_o)
  		else
        match_opening = match_from_unrelated_users(s_o)
  		end
  		create_appointment(s_o, match_opening) if match_opening
  	end
  end

  def match_from_related_users(specific_opening)
    partners = specific_opening.user.appointment_partners
    if partners.present?
      if specific_opening.user.is_tutor?
        return nil if !specific_opening.confirmed?
        opening = partners.map(&:specific_openings).flatten.detect do |s_o|
          s_o.scheduled_for == specific_opening.scheduled_for && 
            s_o.still_on?
        end
      else 
        return nil if !specific_opening.still_on?
        opening = partners.map(&:specific_openings).flatten.detect do |s_o|
          s_o.scheduled_for == specific_opening.scheduled_for && 
            s_o.confirmed?
        end
      end 
    end
  end

  def match_from_unrelated_users(specific_opening)
    return nil if (specific_opening.user.is_tutor? && specific_opening.status != 'confirmed')
    return nil if (!specific_opening.user.is_tutor? && specific_opening.status != 'requested_confirmation')
    tutor_opening = SpecificOpening.after(specific_opening.scheduled_for - 10.minutes).
    before(specific_opening.scheduled_for + 10.minutes).where(user_role: specific_opening.user.is_tutor? ? 'tutee' : 'tutor', 
    status: specific_opening.user.is_tutor? ? 'requested_confirmation' : 'confirmed' ).first
  end

  def upcoming?(specific_opening)
    Time.current.utc + 1.hour + 30.minutes > specific_opening.scheduled_for
  end

 def create_appointment(opening, match_opening)
  	if opening.user.is_tutor?
  		tutor_opening = opening
  		tutee_opening = match_opening
  	else
  		tutee_opening = opening
  		tutor_opening = match_opening
  	end
  	
  	apt = Appointment.create(tutor_id: tutor_opening.user.id, 
  		tutee_id: tutee_opening.user.id, 
  		scheduled_for: tutor_opening.scheduled_for.utc, 
      start_page: last_finish_page(tutee_opening.user)
      )
  	opening.update_attributes(status: 'taken', appointment_id: apt.id)
  	match_opening.update_attributes(status: 'taken', appointment_id: apt.id)
  end

  def last_finish_page(tutee)
    @start_page = tutee.most_recent_before_today.finish_page 
  end
end