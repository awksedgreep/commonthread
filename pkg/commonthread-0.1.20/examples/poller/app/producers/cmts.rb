require 'ostruct'

# Producers usually get jobs/objects from a model and put them in a queue for consumers to consume
class CmtsProducer < Producer
   # Most functionality is built in, but you will likely want to overload/replace event_loop method
   #def event_loop
   #   every 5.minutes
   #   puts "do my stuff here"
   #end
   def event_loop
      every 10.seconds
      # Generally this would pull CMTS from the DB using ActiveRecord, but this will
      # suffice for example purposes
      i = 100
      'CMTS01'.upto('CMTS50') do |cmts|
         os = OpenStruct.new
         os.hostname = cmts
         os.ip_address = '192.168.0.' + (i += 1).to_s
         os.read_string = 'Go'
         @q << os
      end
   end
end
