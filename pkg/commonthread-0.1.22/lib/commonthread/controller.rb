#!/usr/bin/env ruby

require 'drb'

# Controller is a manager of a group of producers, consumers, and their respective queues
class Controller
   include DRbUndumped

   DefaultConfig = { :log => $log }
   attr_accessor :queues, :producers, :consumers, :log, :config

   def initialize(config = {})
      @config = DefaultConfig.merge(config)
      @queues = {}
      @producers = {}
      @consumers = {}
      @log = @config[:log]
      if @log.nil?
         @log = Log.new(:application => 'CommonThread', :log_level => Logger::DEBUG)
         @logconsumer = LogConsumer.new(@log, STDOUT)
      end
      # Register controller
      $controllers = [] if $controllers.nil?
      $controllers << self
      trap "TERM", proc { shutdown }
      trap "KILL", proc { kill }
   end

   # Status for all producers, consumers, and queues managed by this controller
   def status
      @log.debug("Controller: Status Called")
      res = {
        :queues    => q_status,
        :producers => producer_status,
        :consumers => consumer_status
      }
   end
   
   # Stats for all producers and consumers managed by this controller
   def stats
      @log.debug("Controller: Stats Called")
      res = {
        :producers => producer_stats,
        :consumers => consumer_stats
      }
   end

   # Add a named queue
   def add_q(name, q = nil)
      @log.info("Controller: Adding Queue: #{name}")
      @queues[name] = Queue.new if q.nil?
   end
   
   # Factory for queues, nice for DRb so there's no confusion as to where the object is instantiated
   def create_q(name)
      @log.info("Controller: Creating Queue: #{name}")
      add_q(name)
   end

   # Delete a named queue
   def del_q(name)
      # Should I shut it down first?  Is there a way to tell a queue to stop accepting input,
      # wait until it's empty then go away?  Future enhancement
      @log.info("Controller: Deleting Queue: #{name}")
      @queues.delete(name)
   end

   # Get queue status
   def q_status
      @log.debug("Controller: Queue Status Called")
      res = {}
      @queues.each do |key, value|
         res[key] = value.status
      end
      res
   end

   # Add a named producer
   def add_producer(name, producer)
      @log.info("Controller: Adding Producer: #{name}")
      @producers[name] = producer
   end

   # Delete a named producer -- User is expected to shut it down first, however in the future
   # I may shut it down for the user before deleting it
   def del_producer(name)
      @log.info("Controller: Deleting Producer: #{name}")
      @producers.delete(name)
   end

   # Shut down a named producer -- This is the nice shutdown which asks the threads nicely to
   # go away
   def shutdown_producer(name)
      @log.info("Controller: Shutting Down Producer: #{name}")
      @producers[name].shutdown
   end

   # Shut down all producers registered with this controller, again shutdown is nice, kill is not
   def shutdown_producers
      @log.info("Controller: Shutting Down All Producers")
      @producers.each do |key, producer|
         @log.debug("Controller: Shutting Down #{key}")
         producer.shutdown
      end
   end

   # Kill named producer immediately, not nice
   def kill_producer(name)
      @log.info("Controller: Killing Producer: #{name}")
      @producers[name].kill
   end

   # Kill all producers immediately, not nice
   def kill_producers
      @log.info("Controller: Killing Producers")
      @producers.each do |key, producer|
         producer.kill
      end
   end

   # Get status for all producers managed by this controller
   def producer_status
      @log.debug("Controller: Producer Status Called")
      res = {}
      @producers.each do |key, value|
         res[key] = value.status
      end
      res
   end
   
   # Get stats for all producers managed by this controller
   def producer_stats
      @log.debug("Controller: Producer Stats Called")
      res = {}
      @producers.each do |key, value|
         res[key] = value.stats
      end
      res
   end

   # Add a named consumer thread group
   def add_consumer(name, consumer)
      @log.info("Controller: Adding Consumer: #{name}")
      @consumers[name] = consumer
   end

   # Delete a named consumer thread group
   def del_consumer(name)
      @log.info("Controller: Deleting Consumer #{name}")
      @consumer.delete(name)
   end

   # Shutdown named consumer group nice (empties queue first, might take a while)
   def shutdown_consumer(name)
      @log.info("Controller: Shutting Down Consumer: #{name}")
      @consumers[name].shutdown
   end

   # Shutdown all consumer groups (empties queue first, might take a while)
   def shutdown_consumers
      @log.info("Controller: Shutting Down All Consumers")
      @consumers.each do |key, consumer|
         consumer.shutdown
      end
   end

   # Kill named consumer immediately, not nice
   def kill_consumer(name)
      @log.info("Controller: Killing Consumer: #{name}")
      @consumers[name].kill
   end

   # Kill all consumers now, not nice
   def kill_consumers
      @log.info("Controller: Killing Consumers")
      @consumers.each do |key, consumer|
         consumer.kill
      end
   end

   # Get status of all consumers
   def consumer_status
      @log.debug("Controller: Consumer Status Called")
      res = {}
      @consumers.each do |key, value|
        res[key] = value.status
      end
      res
   end
   
   # Get status of all consumers
   def consumer_stats
      @log.debug("Controller: Consumer Stats Called")
      res = {}
      @consumers.each do |key, value|
         res[key] = value.stats
      end
      res
   end

   # Shutdown all producers and consumers managed by this controller
   def shutdown
      @log.info("Controller: Shutdown Called")
      shutdown_producers
      shutdown_consumers
   end

   # Kill all producers and consumers immediately, not nice
   def kill
      @log.info("Controller: Kill Called")
      kill_producers
      kill_consumers
   end

   # Create methods available via XMLRPC, if they aren't specified in subclass creation with
   # xmlrpc_methods then they will not be allowed access via the web service.
   # Example:
   # class MyController < Controller
   #    register_xmlrpc :status, :producer_status, :consumer_status, :queue_status, :shutdown
   # end
   def self.register_xmlrpc(*args)
      args = ['status', 'producer_status', 'consumer_status', 'queue_status'] if args.nil?
      args.each do |arg|
         class_eval <<-end_of_eval
            def self.xmlrpc_methods; ["#{args.join('", "')}"]; end
         end_of_eval
      end
   end
end
