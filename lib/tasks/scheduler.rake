desc "This task is called by the Heroku scheduler add-on"

task :build_specific_openings => :environment do
  puts "build_specific_openings"
	sob = SpecificOpeningBuilder.new
	sob.add_and_build_all_openings
  puts "done."
end

task :create_appointments => :environment do
  tutor_so = SpecificOpening.today.where(status: 'confirmed', user_role: 'tutor')
  tutee_so = SpecificOpening.today.where(status: 'requested_confirmation', user_role: 'tutee')
	som = SpecificOpeningMatcher.new(tutor_so  + tutee_so)
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


