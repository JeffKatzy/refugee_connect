class SpecificOpeningMatcher
	attr_accessor :specific_openings

	def initialize(specific_openings)
		@specific_openings = specific_openings
	end

	def matches_and_creates_apts
  	specific_openings.select{ |s_o| s_o.status == 'confirmed'}.each do |confirmed_s_o|
  		if !confirmed_s_o.upcoming?
        match_opening = confirmed_s_o.match_from_related_users 
  		else
        match_opening = confirmed_s_o.match_from_unrelated_users  
  		end
  		create_appointment(confirmed_s_o, match_opening) if match_opening
  	end
  end

  private

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
  		scheduled_for: tutor_opening.scheduled_for.utc)
  	opening.update_attributes(status: 'taken', appointment_id: apt.id)
  	match_opening.update_attributes(status: 'taken', appointment_id: apt.id)
  end
end