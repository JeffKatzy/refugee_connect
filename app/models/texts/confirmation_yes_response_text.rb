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

	def last_confirmation
		specific_opening.confirmations.last
	end

	def helper_url
		Rails.application.routes.url_helpers.specific_opening_confirmation_path(specific_opening, last_confirmation)
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
			"OK! We'll match you up and text you at #{specific_opening.scheduled_for_time_to_text}. You'll need your phone and book. Click #{BASE_URL + helper_url} for the book and other info."
		else
			"OK! We'll match you up and text you at #{specific_opening.scheduled_for_time_to_text}. You'll need your phone and book. Click #{BASE_URL + helper_url} for the book and other info."
		end
	end
end

