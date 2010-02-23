#!/usr/bin/env ruby

# Some helpful environmentals for Integer to better work with Time.
#  Usage:
#   3.pm + 10.minutes
#   5.hours
#   1.minute
#   6.days
#   10.seconds
#   2.days.from_now
#   1.minute.ago
class Integer
   def seconds
      self
   end
   alias second seconds

   def minutes
      self * 60
   end
   alias minute minutes

   def hours
      self * 60 * 60
   end
   alias hour hours

   def days
      self * 86400
   end
   alias day days

   def ago
      Time.now - self
   end

   def from_now
      Time.now + self
   end

   def am
      Time.now.today + (self * 60 * 60)
   end

   def pm
      Time.now.today + (self * 60 * 60) + 43200
   end

   def epoch
      Time.at(self) - (DateTime.now.offset.to_f * 86400)
   end
end

# Utility methods added to Time for quick calculations
#  Usage:
#   Time.now.seconds_since_midnight => Int
#   Time.now.midnight => Time
#   Time.now.tomorrow => Time
#   Time.now.offset => Int # TZ Offset in Seconds
class Time
   def seconds_since_midnight
      self.hour.hours + self.min.minutes + self.sec + (self.usec/1.0e+6)
   end

   def midnight
      self - self.seconds_since_midnight
   end
   alias today midnight

   def tomorrow
      self + 86400
   end
   alias every_day tomorrow

   def my_epoch
      Time.at(0) - (DateTime.now.offset.to_f * 86400).floor
   end

   def offset
      (DateTime.now.offset.to_f * 86400).floor
   end
end

# Handy little function for threads, sleeps(very cpu friendly) until next iteration 
# of interval.  After mucho work, intervals now sit on "natural" boundaries per local tz
#  Usage:
#   every(3.minutes)
#   every(10.seconds)
def every(interval)
   # Time.now.to_f returns epoch at meridian, we want local for math
   (garbage, remainder) = (Time.now.to_f + Time.now.offset).divmod(interval)
   sleep interval - remainder
   yield if block_given?
end

# Similar to unix at for threads.  Sleeps until designated time.
#  Usage:
#   at(3.pm) do process_batch; puts "batch complete" end
#   at(9.am + 10.minutes)
#   at(Time.now + 1.hour) do puts "been waitin' here" end
def at(time)
   time = time.to_time if time.class == String
   # If time.to_f - Time.now.to_f is negative, do tomorrow instead
   time = time.tomorrow if time.to_f <= Time.now.to_f
   diff = time.to_f - Time.now.to_f
   puts "sleeping #{diff} until #{Time.now + diff}" unless $debug.nil?
   sleep diff
   yield if block_given?
end

# Utility function for day.  Allows phrases like the following:
#  Usage:
#   every day { at 9.pm { print Time.now.to_s + "\n" } }
def day
   86400
end

# Utility function for week.  Allows phrases like the following:
#  Usage:
#   every week { at 10.pm { print Time.now.to_s + "\n" } }
def week
   86400 * 7
end

# Utility function for now.  Allows Time.now to be shortened to just "now"
def now
   Time.now
end
