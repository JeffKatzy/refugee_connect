# == Schema Information
#
# Table name: texts
#
#  id                :integer          not null, primary key
#  body              :string(255)
#  user_id           :integer
#  unit_of_work_id   :integer
#  unit_of_work_type :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  type              :string(255)
#

class BeginSessionText < Text
	after_create :set_type
	BASE_URL = 'www.speakloud.org'

	def helper_url
		@helper_url = Rails.application.routes.url_helpers.appointment_path(self.appointment)
	end


	def set_type
		self.unit_of_work_type = 'Appointment'
		save
	end

	def appointment
		unit_of_work
		save
		unit_of_work
	end

	def body
		if user.is_tutor?
			"Your class with #{self.appointment.tutee.name} is on!! Go to #{BASE_URL + helper_url} for your class info.  Then, reply to this text with the word 'Go' to begin."
		else
			"Your class with #{self.appointment.tutor.name} now ready!! You will be receiving a call shortly."
		end
	end
end