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
	BASE_URL = 'www.speakloud.org'

	def specific_opening
		unit_of_work
	end

	def set_type
		self.unit_of_work_type = 'SpecificOpening'
		save
	end

	def helper_url
		Rails.application.routes.url_helpers.new_specific_opening_confirmation_path(specific_opening)
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
		time = specific_opening.scheduled_for_to_text(user.role)
		if user.is_tutor?
			"Speakloud session today at #{time}!! Text 'Y' and we match you with someone to teach. Text 'N' to cancel. Or click #{BASE_URL + helper_url} to confirm online."
		else
			"You have a session today at #{time}!!  Text back 'Y' and we'll match you with a teacher. Or text 'N' to cancel. Or click #{BASE_URL + helper_url} to confirm online."
		end
	end
end