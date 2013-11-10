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
    Appointment.batch_create(params[:user_id], params[:match_id])
    redirect_to appointments_path
  end

  def index
    @appointments = @auth.appointments.next_appointments
  end

  def askpagenumber 
    @appointment = Appointment.find(params[:id])
    tutor = User.find(@appointment.tutor)
    TextToUser.deliver(tutor, 'Please text the page number that you last left off at.')
  end
end