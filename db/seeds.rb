# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  cell_number     :string(255)
#  role            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin           :boolean
#  name            :string(255)
#  active          :boolean
#

# == Schema Information
#
# Table name: availability_managers
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  per_week      :integer
#  schedule_hash :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
User.delete_all
AvailabilityManager.delete_all
Appointment.delete_all

u1 = User.create(email: 'jeff@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor', name: 'Jeff')
u2 = User.create(email: 'evan@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor', name: 'Sam')
u3 = User.create(email: 'matt@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor', name: 'Adam')
u4 = User.create(email: 'bob@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor', name: 'Paul')
u5 = User.create(email: 'smith@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor', name: 'Michael')
u6 = User.create(email: 'tommy@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor', name: 'Bob')

u7 = User.create(email: 'rishi@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutee', name: 'Rishi')
u8 = User.create(email: 'Roshni@gmail.com', password_digest: 'passit', cell_number: '215-499-7415', role: 'tutee', name: 'Roshni')
u9 = User.create(email: 'Ruchi@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutee', name: 'Ruchi')
u10 = User.create(email: 'Nitika@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutee', name: 'Nitika')
u11 = User.create(email: 'jaya@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutee', name: 'Jaya')
u12 = User.create(email: 'jot@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutee', name: 'Prabhjot')

User.all.each do |user|
	user.password_digest = BCrypt::Password.create(user.password_digest).to_s
	user.save
end

am1 = AvailabilityManager.create(per_week: 6)
am2 = AvailabilityManager.create(per_week: 6)
am3 = AvailabilityManager.create(per_week: 6)
am4 = AvailabilityManager.create(per_week: 6)
am5 = AvailabilityManager.create(per_week: 6)
am6 = AvailabilityManager.create(per_week: 6)

am1.add_weekly_availability('tuesday', 4)
am2.add_weekly_availability('wednesday', 5)
am3.add_weekly_availability('thursday', 6)
am4.add_weekly_availability('friday', 7)
am5.add_weekly_availability('saturday', 8)
am6.add_weekly_availability('sunday', 9)

am2.add_weekly_availability('tuesday', 4)
am3.add_weekly_availability('wednesday', 5)
am4.add_weekly_availability('thursday', 6)
am5.add_weekly_availability('friday', 7)
am1.add_weekly_availability('saturday', 8)
am6.add_weekly_availability('monday', 9)

am3.add_weekly_availability('tuesday', 4)
am4.add_weekly_availability('wednesday', 5)
am5.add_weekly_availability('thursday', 6)
am1.add_weekly_availability('friday', 7)
am2.add_weekly_availability('saturday', 8)
am6.add_weekly_availability('monday', 3)

am4.add_weekly_availability('tuesday', 4)
am5.add_weekly_availability('wednesday', 5)
am1.add_weekly_availability('thursday', 6)
am2.add_weekly_availability('friday', 7)
am3.add_weekly_availability('saturday', 8)
am6.add_weekly_availability('tuesday', 4)

am5.add_weekly_availability('tuesday', 4)
am1.add_weekly_availability('wednesday', 5)
am2.add_weekly_availability('thursday', 6)
am3.add_weekly_availability('friday', 7)
am4.add_weekly_availability('saturday', 8)
am6.add_weekly_availability('wednesday', 7)

u1.availability_manager = am1
u2.availability_manager = am2
u3.availability_manager = am3
u4.availability_manager = am4
u5.availability_manager = am5
u6.availability_manager = am6

am7 = AvailabilityManager.create(per_week: 6)
am8 = AvailabilityManager.create(per_week: 6)
am9 = AvailabilityManager.create(per_week: 6)
am10 = AvailabilityManager.create(per_week: 6)
am11 = AvailabilityManager.create(per_week: 6)
am12 = AvailabilityManager.create(per_week: 6)

am7.add_weekly_availability('tuesday', 4)
am8.add_weekly_availability('wednesday', 5)
am9.add_weekly_availability('thursday', 6)
am10.add_weekly_availability('friday', 7)
am11.add_weekly_availability('saturday', 8)
am12.add_weekly_availability('sunday', 9)

am8.add_weekly_availability('tuesday', 4)
am9.add_weekly_availability('wednesday', 5)
am10.add_weekly_availability('thursday', 6)
am11.add_weekly_availability('friday', 7)
am12.add_weekly_availability('saturday', 8)
am7.add_weekly_availability('monday', 9)

am9.add_weekly_availability('tuesday', 4)
am10.add_weekly_availability('wednesday', 5)
am11.add_weekly_availability('thursday', 6)
am12.add_weekly_availability('friday', 7)
am7.add_weekly_availability('saturday', 8)
am8.add_weekly_availability('monday', 3)

am10.add_weekly_availability('tuesday', 4)
am11.add_weekly_availability('wednesday', 5)
am12.add_weekly_availability('thursday', 6)
am7.add_weekly_availability('friday', 7)
am8.add_weekly_availability('saturday', 8)
am9.add_weekly_availability('tuesday', 4)

am11.add_weekly_availability('tuesday', 4)
am12.add_weekly_availability('wednesday', 5)
am7.add_weekly_availability('thursday', 6)
am8.add_weekly_availability('friday', 7)
am9.add_weekly_availability('saturday', 8)
am10.add_weekly_availability('wednesday', 7)

am12.add_weekly_availability('tuesday', 4)
am7.add_weekly_availability('wednesday', 5)
am8.add_weekly_availability('thursday', 6)
am9.add_weekly_availability('friday', 7)
am10.add_weekly_availability('saturday', 8)
am11.add_weekly_availability('wednesday', 7)

u7.availability_manager = am7
u8.availability_manager = am8
u9.availability_manager = am9
u10.availability_manager = am10
u11.availability_manager = am11
u12.availability_manager = am12

a1 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 30.minutes, began_at: Time.now - 40.minutes, ended_at: Time.now - 40.minutes + 1.hour)
a2 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 1.hour, began_at: Time.now - 1.hour + 10.minutes, ended_at: Time.now - 1.hour + 10.minutes + 1.hour)
a3 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 2.hours, began_at: Time.now - 2.hours + 10.minutes, ended_at: Time.now - 2.hours + 10.minutes + 1.hour)
a4 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 3.hours, began_at: Time.now - 3.hours, ended_at: Time.now - 3.hours + 1.hour)
a5 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 4.hours, began_at: Time.now - 4.hours + 20.minutes, ended_at:  Time.now - 4.hours + 20.minutes + 1.hour)
a6 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 20.minutes, began_at: Time.now - 30.minutes, ended_at: Time.now - 30.minutes + 1.hour)
a7 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 1.day, began_at: Time.now - 1.day, ended_at: Time.now - 1.day + 1.hour)
a8 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 2.days, began_at: Time.now - 2.days, ended_at: Time.now - 2.days + 1.hour)
a9 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now - 3.days, began_at: Time.now - 3.days, ended_at:  Time.now - 3.days + 1.hour)
a10 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 1.day, began_at: Time.now + 1.day, ended_at: Time.now + 1.day + 1.hour)
a11 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 2.days, began_at: Time.now + 2.days, ended_at: Time.now + 2.days + 1.hour)
a12 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 6.days, began_at: Time.now + 6.days, ended_at: Time.now + 6.days + 1.hour) 
a13 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 1.week, began_at: Time.now + 1.week, ended_at: Time.now + 1.week + 1.hour)
a14 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 2.weeks, began_at: Time.now + 2.weeks, ended_at: Time.now + 2.weeks + 1.hour)
a15 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 3.weeks, began_at: Time.now + 3.weeks, ended_at: Time.now + 3.weeks + 2.hours)
a16 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 45.minutes, began_at: Time.now + 45.minutes, ended_at: Time.now + 45.minutes + 20.minutes)
a17 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 20.minutes, began_at: Time.now + 45.minutes + 1.hour)
a18 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 10.minutes, began_at: Time.now + 45.minutes)
a19 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 4.hours, began_at: Time.now + 45.minutes)
a20 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 5.hours, began_at: Time.now + 45.minutes)
a21 = Appointment.create(status: 'incomplete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 6.hours)
a22 = Appointment.create(status: 'incomplete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 2.hours)
a23 = Appointment.create(status: 'incomplete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 3.hours)
a24 = Appointment.create(status: 'incomplete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 1.hour)
a25 = Appointment.create(status: 'incomplete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 2.hours)
a25 = Appointment.create(status: 'incomplete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 3.hours)

a1.tutor = u1
a1.tutee = u7
a1.save

a2.tutor = u2
a2.tutee = u8
a2.save

a3.tutor = u3
a3.tutee = u9
a3.save

a4.tutor = u4
a4.tutee = u10
a4.save

a5.tutor = u5
a5.tutee = u11
a5.save

a6.tutor = u6
a6.tutee = u12
a6.save

a7.tutor = u1
a7.tutee = u7
a7.save

a8.tutor = u2
a8.tutee = u8
a8.save

a9.tutor = u3
a9.tutee = u9
a9.save

a10.tutor = u4
a10.tutee = u10
a10.save

a11.tutor = u5
a11.tutee = u11
a11.save

a12.tutor = u6
a12.tutee = u12
a12.save

a13.tutor = u1
a13.tutee = u7
a13.save

a14.tutor = u2
a14.tutee = u8
a14.save

a15.tutor = u3
a15.tutee = u9
a15.save

a16.tutor = u4
a16.tutee = u10
a16.save

a17.tutor = u5
a17.tutee = u11
a17.save

a18.tutor = u6
a18.tutee = u12
a18.save

a19.tutor = u1
a19.tutee = u7
a19.save

a20.tutor = u2
a20.tutee = u8
a20.save

a21.tutor = u3
a22.tutee = u9
a22.save

a23.tutor = u4
a23.tutee = u10
a23.save

a24.tutor = u5
a24.tutee = u11
a24.save

a25.tutor = u6
a25.tutee = u12
a25.save

a25.tutor = u1
a25.tutee = u12
a25.save




