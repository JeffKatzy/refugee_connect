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

class NoPotentialMatchText < Text
	after_create :set_type, :set_user, :set_body
	BASE_URL = 'www.speakloud.org'

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
		save
	end

	def body
		"Sorry! There is no one available for your speakloud session today.  Don't worry.  We'll try again next week!"
	end
end
