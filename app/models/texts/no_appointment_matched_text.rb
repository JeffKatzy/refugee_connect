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

class NoAppointmentMatchedText < Text
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
		self.body = "Sorry! We could not find someone for your appointment today.  This happens every once in a while.  We should be able to find someone for you next time."
		save
	end
end
