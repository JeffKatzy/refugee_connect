class AppointmentsController < ApplicationController

  def calluser #this connects the student to the refugee in the scheduled phone call
    @appointment = Appointment.find(params[:id])
    @tutor = @appointment.tutor
    @tutee = @appointment.tutee

    respond_to do |format|
      format.xml { @tutee }
      format.xml { @tutor }
    end
  end

  def batch
    Appointment.batch(@auth, params[:match_id])
    redirect_to appointments_path
  end

  def index
    @appointments = @auth.appointments.next_appointments
  end
    
end