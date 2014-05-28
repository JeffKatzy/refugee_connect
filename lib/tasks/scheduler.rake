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

task :confirm_apts => :environment do
  puts "gather apts in just before"
  ReminderText.confirm_specific_openings
  puts "done."
end


