desc "This task is called by the Heroku scheduler add-on"

task :build_specific_openings => :environment do
  puts "build_specific_openings"
	sob = SpecificOpeningBuilder.new
	sob.add_and_build_all_openings
  puts "done."
end

task :create_appointments => :environment do
  specific_openings = SpecificOpening.today.where(status: 'confirmed')
	som = SpecificOpeningMatcher.new(specific_openings)
	som.matches_and_creates_apts
end

task :confirm_apts => :environment do
  puts "gather apts in just before"
  ReminderText.confirm_specific_openings
  puts "done."
end

task :begin_session_text => :environment do
  puts "beginning session"
  ReminderText.begin_session
  puts "done."
end

# task :set_page_number => :environment do
#   puts "set page number"
#   ReminderText.set_page_number
#   puts "done."
# end


