class AppointmentsController < ApplicationController
  def calluser #this connects the student to the refugee in the scheduled phone call
    @appointment = Appointment.find(params[:id])
    @tutor = User.find(@appointment.tutor)
    @tutee = User.find(@appointment.tutee)

      respond_to do |format|
        format.xml { @tutee_number }
        format.xml { @user_name }
      end
  end
end