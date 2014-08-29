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
			"You gotta speakloud session today!! Can you still teach at #{time}?  Text back 'Y' and we'll find you a match who is also free today, or text 'N' and we'll find another teacher."
		else
			"You have a session today at #{time}.  If you cannot attend the class, do not answer the phone when you receive the call."
		end
	end
end
