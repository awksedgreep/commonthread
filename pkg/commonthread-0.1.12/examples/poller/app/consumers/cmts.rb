# Consumers generally read from queues, but are not limited to that
class CmtsConsumer < Consumer
   # Most functionality is built in, but you will likely want to overload/replace event_loop method
   #def event_loop
   #   every 5.minutes
   #   puts "do my stuff here"
   #end
   def event_loop
      cmts = @q.pop
      cmts.poll = 'done'
      @log.debug "CmtsConsumer: Finished polling #{cmts.ip_address}"
   end
end
