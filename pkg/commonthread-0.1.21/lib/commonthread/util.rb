#!/usr/bin/env ruby

# Add trim . . . ruby oversight
class String
   def trim
      self.gsub!(/^\s+/, '')
      self.gsub!(/\s+$/, '')
   end

   def to_time
      Time.parse(self)
   end
end

# Thread safe counter
class Counter
   include MonitorMixin
   attr_reader :count

   def initialize
      @count = 0
      super
   end
   
   def tick
      synchronize do
         @count += 1
      end
   end
   alias iterate tick
   
   def to_i
     @count
   end
   
   def reset
     synchronize do
       @count = 0
     end
   end
   
   def set(value)
     synchronize do
       @count = value
     end
   end
end
      
