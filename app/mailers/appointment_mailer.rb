class AppointmentMailer < ActionMailer::Base
  default from: "jek2141@columbia.edu"

  def log_creation_email
    mail(to: "JeffreyEricKatz@gmail.com", subject: 'Welcome to My Awesome Site')
  end

  def self.users_available_this_week(role) # pass in tutors or tutees
  	@available_users = []
  	User.active.send(role).each do |u|
  		if u.wants_more_appointments_before(Time.current.end_of_week)
  			@available_users << u
  		end
  	end
  	@available_users
  end

  def self.users_with_appointments_this_week(role) # pass in tutors or tutees
  	@users_with_apts = []
  	Appointment.this_week.each do |apt|
  		if role == 'tutors'
  			@tutees_with_apts << apt.tutor
  		else
  			@tutees_with_apts << apt.tutee
  		end
  	end
  	@tutees_with_apts
  end

  def self.available_users_without_apts(role)
  	uavailable = users_available_this_week(role) 
  	uapts = users_with_appointments_this_week(role)
  	if uapts.nil?
  		users = uavailable
  	else
  		users = uavailable - uapts
  	end
  end
end
