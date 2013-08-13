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

u1 = User.create(email: 'jeff@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor')
u2 = User.create(email: 'evan@gmail.com', password_digest: 'passit', cell_number: '215-499-7415', role: 'tutor')
u3 = User.create(email: 'matt@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor')
u4 = User.create(email: 'bob@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor')
u4 = User.create(email: 'smith@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor')
u5 = User.create(email: 'tommy@gmail.com', password_digest: 'password', cell_number: '215-499-7415', role: 'tutor')

am1 = AvailabilityManager.create(per_week: 3)
am2 = AvailabilityManager.create(per_week: 4)
am3 = AvailabilityManager.create(per_week: 5)
am4 = AvailabilityManager.create(per_week: 2)
am5 = AvailabilityManager.create(per_week: 3)

am1.add_weekly_availability('tuesday', 4)
am2.add_weekly_availability('wednesday', 5)
am3.add_weekly_availability('thursday', 6)
am4.add_weekly_availability('friday', 7)
am5.add_weekly_availability('saturday', 8)

u1.availability_manager = am1
u2.availability_manager = am2
u3.availability_manager = am3
u4.availability_manager = am4
u5.availability_manager = am5

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
a21 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 6.hours)
a22 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 2.hours)
a23 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 3.hours)
a24 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 1.hour)
a25 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 2.hours)
a25 = Appointment.create(status: 'complete', start_page: 1, finish_page: 2, scheduled_for: Time.now + 3.hours)

u1.appointments << [a1, a6, a11, a16, a21] 
u2.appointments << [a2, a7, a12, a17, a22]
u3.appointments << [a3, a8, a13, a18, a23]
u4.appointments << [a4, a9, a14, a19, a24]
u5.appointments << [a5, a10, a15, a20, a25]


# == Schema Information
#
# Table name: appointments
#
#  id            :integer          not null, primary key
#  status        :string(255)
#  start_page    :integer
#  finish_page   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  scheduled_for :text
#  user_id       :integer
#  began_at      :datetime
#  ended_at      :datetime
#

