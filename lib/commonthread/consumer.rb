#!/usr/bin/env ruby

#Thread.abort_on_exception = true

# All methods are inherited from Producer.  
# See Producer class for more documentation.
class Consumer < Producer
   # Example event loop, this should be replaced with either a block,
   # or overloading
   def event_loop
      # If a block was provided, execute it (same as Producer)
      if @event_loop_block
         instance_eval(&@event_loop_block)
      elsif q.class == Queue
         res = q.deq
         return :shutdown if res == :shutdown  # Exit gracefully on shutdown sentinel
         @log.debug "Consumer: Processing " + res.class.to_s
         print "#{res}\n"
      else
         every 30.seconds
         print Thread.current['tid'].to_s << " => " << Time.now.to_s << "\n"
      end
   end
end

# See Producer class for more documentation.
class Job < Producer
   # Example event loop, this should be replaced with either a block,
   # or overloading
   def event_loop
      # If a block was provided, execute it (same as Producer)
      if @event_loop_block
         instance_eval(&@event_loop_block)
      elsif q.class == Queue
         res = q.deq
         return :shutdown if res == :shutdown  # Exit gracefully on shutdown sentinel
         @log.debug "Consumer: Processing " + res.class.to_s
         print "#{res}\n"
      else
         every 30.seconds
         print Thread.current['tid'].to_s << " => " << Time.now.to_s << "\n"
      end
   end
end
