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
