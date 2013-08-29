module IceTime

  attr_accessor :schedule

  def init_schedule(time)
    @schedule = IceCube::Schedule.new(time, :duration => 3600)
  end

  def add_weekly_availability(day, hour)
    time = convert_to_time(hour)
    init_schedule(time) if @schedule.nil?
    add_recurrence_to(schedule, day)
    save_schedule
  end

  def add_recurrence_to(schedule, day)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(day.downcase.to_sym)
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
    schedule.occurrences(Time.now.end_of_week).select { |time| time > Time.now.beginning_of_week && time < Time.now.end_of_week }
  end
end