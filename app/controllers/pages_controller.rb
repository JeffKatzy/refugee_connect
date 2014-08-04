class PagesController < ApplicationController
layout 'pages'
  def home
  	@user = User.new
  end

  def admin
  	@specific_openings = SpecificOpening.today
  	@specific_openings_tomorrow = SpecificOpening.tomorrow
  	@appointments = Appointment.after(Time.current.utc.beginning_of_day).before(Time.current.utc.end_of_day)
  end
end