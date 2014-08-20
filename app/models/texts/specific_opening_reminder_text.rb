class SpecificOpeningReminderText < Text
	after_create :set_type, :set_user, :set_body

	def specific_opening
		unit_of_work
	end

	def set_type
		self.unit_of_work_type = 'SpecificOpening'
		save
	end

	def set_user
		self.user_id = specific_opening.user_id
		save
	end

	def set_body
		self.body = body
	end

	def body
		time = specific_opening.scheduled_for_to_text(user.role)
		if user.is_tutor?
			"Can you still teach at #{time}?  Text back 'Y' to confirm or text 'N' to cancel."
		else
			"You have a session today at #{time}.  If you cannot attend the class, do not answer the phone when you receive the call."
		end
	end
end
