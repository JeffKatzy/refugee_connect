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
    if @auth.is_tutor?
      @appointment.set_scheduled_for_est(params[:appointment])
    else
      @appointment.set_scheduled_for_ist(params[:appointment])
    end
    if @appointment.previous_changes.keys.include?("scheduled_for")
      @appointment.status = 'pending'
      @appointment.save
    end
    respond_with @appointment
  end

  def show
    @appointment = Appointment.find(params[:id])
    @tutor = @appointment.tutor
    @user = @appointment.tutee
    @tutee_profile_info = @user.profile_info || @user.create_profile_info
    if params[:page]
      @appointment.finish_page = params[:page]
      @appointment.save
      @bookpages = Attachinary::File.where(attachinariable_type: 'Bookpage').page(params[:page]).per_page(1)
    else
      @bookpages = Attachinary::File.where(attachinariable_type: 'Bookpage').page(@appointment.start_page).per_page(1)
    end
  end
end