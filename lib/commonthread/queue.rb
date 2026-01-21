#!/usr/bin/env ruby

require 'drb'

# Standard lib thread safe queue with a status addition
class Queue
   include DRbUndumped
   
   def status
      "Waiting: #{num_waiting}  Length: #{length}"
   end
   alias to_s status
   
end

# Same as ruby std lib, with the addition of a status method
# Call it like so:  q = SizedQueue.new(100)
# Whereas 100 is the max size for the queue
class SizedQueue
   include DRbUndumped
   
   def status
      "Size: #{max}  Waiting: #{num_waiting}  Length: #{length}"
   end
   alias to_s status

end
    
