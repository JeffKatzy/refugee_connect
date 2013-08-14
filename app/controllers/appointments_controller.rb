class AppointmentsController < ApplicationController
  def calluser #this connects the student to the refugee in the scheduled phone call
    @appointment = Appointment.find(params[:id])
    @tutor = User.find(@appointment.user)
    @tutee = User.find(@appointment.user)
    @refugee_number = @tutee.cell_number.to_s

      respond_to do |format|
        format.xml { @tutee_number }
        format.xml { @user_name }
      end
  end
end