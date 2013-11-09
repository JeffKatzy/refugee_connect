class AppointmentObserver < ActiveRecord::Observer
  observe :appointment
end