class AppointmentObserver < ActiveRecord::Observer
  observe :appointment

  def after_create(appointment)
  	#update availability manager
  	# AvailabilityManager.remove_availability(appointment.user, appointment.time)
  end
end