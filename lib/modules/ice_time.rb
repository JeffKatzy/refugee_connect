module IceTime

  def init_schedule
    @schedule = IceCube::Schedule.new(duration: 3600)
    @schedule.start_time = Time.now.in_time_zone("America/New_York") - 1.day
    save_schedule
  end

  def add_weekly_availability(day, hour)
    rule = create_rule(day, hour)
    if self.schedule.nil?
      init_schedule 
    else 
    end
    add_recurrence(rule)
  end

  def create_rule(day, hour)
    IceCube::Rule.weekly.day(day.downcase.to_sym).hour_of_day(hour).minute_of_hour(0).second_of_minute(0)
  end

  def add_recurrence(rule)
    schedule.add_recurrence_rule rule
    save_schedule
  end

  def convert_to_time(hour)
    Time.now.change({:hour => hour.to_i,
      :min => 0, :sec => 0 })
  end

  def occurrence_rules
    schedule.recurrence_rules
  end

  def remove_availability(time_period)
    schedule.add_exception_time(time_period)
  end

  def remaining_occurrences_this_week
    schedule.occurrences(Time.now.end_of_week + 1.day).select { |time| time > Time.now }
  end
end