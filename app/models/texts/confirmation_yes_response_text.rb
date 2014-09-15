class ConfirmationYesResponseText < Text
	after_create :set_type, :set_user, :set_body
	BASE_URL = 'www.speakloud.org'

	def specific_opening
		unit_of_work
	end

	def set_type
		self.unit_of_work_type = 'SpecificOpening'
		save
	end

	def helper_url
		Rails.application.routes.url_helpers.specific_opening_confirmation_path(specific_opening)
	end

	def set_user
		self.user_id = specific_opening.user_id
		save
	end

	def set_body
		self.body = body
		save
	end

	def body
		time = specific_opening.scheduled_for_time_to_text
		if user.is_tutor?
			"Cool! We'll match you up and text you at #{specific_opening.scheduled_for_time_to_text}. You'll need your phone and the book. Click #{BASE_URL + helper_url} for the book, and other info."
		else
			"Cool! We'll match you up and text you at #{specific_opening.scheduled_for_time_to_text}. You'll need your phone and the book. Click #{BASE_URL + helper_url} for the book, and other info."
		end
	end
end

