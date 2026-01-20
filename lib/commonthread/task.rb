#!/usr/bin/env ruby

#Thread.abort_on_exception = true

# All methods are inherited from Producer.  
# See Producer class for more documentation.
class Task < Producer
   # Example event loop, this should be replaced with either a block,
   # or overloading
   def event_loop
      # If a block was provided, use it (like Producer does)
      if @event_loop_block
         instance_eval(&@event_loop_block)
      else
         at 5.pm
         # Log controller activity and stats
         @log.info self.class.to_s + ": Controller Status\n" + $controller.first.status.to_yaml
         @log.info self.class.to_s + ": Controller Stats\n" + $controller.first.stats.to_yaml
      end
   end
end
