class AppointmentsController < ApplicationController
  respond_to :html, :json

  def calluser #this connects the student to the refugee in the scheduled phone call
    @appointment = Appointment.find(params[:id])
    @tutor = @appointment.tutor
    @tutee = @appointment.tutee
  end

  def batch
    matches = Match.find(params[:match_id])
    apts = Appointment.batch_create(matches) 
    redirect_to user_path(@auth)
  end

  def index
    @appointments = @auth.appointments.next_appointments
  end

  def complete
    @appointment = Appointment.find(params[:id])
    @appointment.complete
    render status: 200
  end

  def update
    @appointment = Appointment.find(params[:id])
    @appointment.update_attributes(params[:appointment])
    if @appointment.previous_changes.keys.include?("scheduled_for")
      @appointment.status = 'pending'
      @appointment.save
      #eventually notify users of a proposed change
    end
    respond_with @appointment
  end

  def show
  end
end