class SpecificOpeningBuilder < Object
	attr_accessor :openings, :specific_openings

	def initialize(openings = [])
		@openings = openings
		@specific_openings = []
	end

	def add_and_build_all_openings
		@openings = User.active.map(&:openings).flatten unless @openings.present? 
		build_specific_openings
	end

	def build_specific_openings
		@openings.map do |opening|
  			build_s_o(opening)
		end
	end

  private

	def build_s_o(opening)
		Time.zone = opening.user.time_zone
	    Chronic.time_class = Time.zone
	    s_o_time = Chronic.parse(opening.day_open.to_s + " " + opening.time_open.to_s, context: :future)
	    return if already_specific_opening(opening, s_o_time)
	    specific_openings << SpecificOpening.create(user_id: opening.user_id, 
	    	scheduled_for: s_o_time, 
	    	opening_id: opening.id, 
	    	user_role: opening.user.role, 
	    	status: 'available')
  	end

  	def already_specific_opening(opening, s_o_time)
  		opening.specific_openings.after(s_o_time.beginning_of_day).
  			before(s_o_time.end_of_day).presence
  	end
end