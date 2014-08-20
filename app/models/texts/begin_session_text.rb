class BeginSessionText < Text
	after_create :set_type

	def set_type
		self.unit_of_work_type = 'Appointment'
		save
	end

	def appointment
		unit_of_work
	end

	def body
		if user.is_tutor?
			"Your class is now ready!!  Reply to this text with the word 'Go' to begin."
		else
			"Your class is now ready!! You will be receiving a call shortly."
		end
	end
end