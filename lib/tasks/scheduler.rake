desc "This task is called by the Heroku scheduler add-on"
task :begin_session_text => :environment do
  puts "Updating feed..."
  ReminderText.begin_session
  puts "done."
end