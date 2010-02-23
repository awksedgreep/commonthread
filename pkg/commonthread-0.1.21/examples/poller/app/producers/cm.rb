require 'ostruct'

# Producers usually get jobs/objects from a model and put them in a queue for consumers to consume
class CmProducer < Producer
   # Most functionality is built in, but you will likely want to overload/replace event_loop method
   #def event_loop
   #   every 5.minutes
   #   puts "do my stuff here"
   #end
   def event_loop
      every 2.minutes
      0.upto(55) do |octet1|
         0.upto(55) do |octet2|
            0.upto(55) do |octet3|
               os = OpenStruct.new
               os.ip_address = sprintf('10.%d.%d.%d', octet1, octet2, octet3)
               os.mac_address = sprintf('00:00:00:%02x:%02x:%02x', octet1, octet2, octet3)
               os.read_string = 'Run'
               @q << os
            end
         end
      end
   end
end
