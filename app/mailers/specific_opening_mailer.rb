class SpecificOpeningMailer < ActionMailer::Base
  default from: "jek2141@columbia.edu"

  BASE_URL = 'www.speakloud.org'

  def reminder_email(specific_opening)
  	@specific_opening = specific_opening
  	@user = @specific_opening.user
  	@helper_url = Rails.application.routes.url_helpers.specific_opening_path(specific_opening)
  	@url = BASE_URL + @helper_url
  	mail(to: @user.email, subject: "Reminder: Session open at #{@specific_opening.scheduled_for_to_text('tutor')}")
  end
end
