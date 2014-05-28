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

task :confirm_openings => :environment do
    ReminderText.confirm_specific_openings
    puts "done."
  end
end


