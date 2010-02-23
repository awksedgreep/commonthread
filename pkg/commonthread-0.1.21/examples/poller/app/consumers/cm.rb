# Consumers generally read from queues, but are not limited to that
class CmConsumer < Consumer
   # Most functionality is built in, but you will likely want to overload/replace event_loop method
   #def event_loop
   #   every 5.minutes
   #   puts "do my stuff here"
   #end
   def event_loop
      cm = @q.pop
      cm.poll = 'done'
      @log.debug "CmConsumer: Finished polling #{cm.mac_address}"
   end
end
