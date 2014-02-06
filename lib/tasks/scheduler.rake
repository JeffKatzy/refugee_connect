desc "This task is called by the Heroku scheduler add-on"
task :begin_session_text => :environment do
  puts "beginning session"
  ReminderText.begin_session
  puts "done."
end

task :set_page_number => :environment do
  puts "set page number"
  ReminderText.set_page_number
  puts "done."
end

task :reminder_one_day => :environment do
  puts "gathering apts in one day"
  ReminderText.apts_in_one_day
  puts "done."
end

task :just_before_apts => :environment do
  puts "gather apts in just before"
  ReminderText.just_before_apts
  puts "done."
end

task :build_appointments => :environment do
  if Time.current.saturday?
    puts "building weekly appointments"
    Appointment.auto_batch_create()
    puts "done."
  end
end

task :build_matches => :environment do
	if Time.current.saturday?
		puts "building weekly matches matches"
		User.active.each do |user|
			Match.build_all_matches_for(user, Time.current + 7.days)
		end
		puts "done."
	end
end


