#!/usr/bin/env ruby

require 'drb'

# Controller is a manager of a group of producers, consumers, and their respective queues
class Controller
   include DRbUndumped

   DefaultConfig = { :application => 'CommonThread' }
   # Default q is the last queue added
   attr_accessor :queues, :producers, :consumers, :tasks, :log, :config, :default_q, :application

   def initialize(config = {})
      @config = DefaultConfig.merge(config)
      @queues = {}
      @producers = {}
      @consumers = {}
      @tasks = {}
      @log = @config[:log]
      @application = config[:application]
      if @log.nil?
         @log = Log.new(:application => @application, :log_level => Logger::DEBUG)
         @logconsumer = LogConsumer.new(@log, File.open(Dir.getwd + '/log/' + @application + '.log', 'a'))
      end
      # Register controller
      $controller = self
      trap "TERM", proc { shutdown }
      trap "KILL", proc { kill }
   end

   # Status for all producers, consumers, and queues managed by this controller
   def status
      @log.debug("Controller: Status Called")
      res = {
        :queues    => q_status,
        :producers => producer_status,
        :consumers => consumer_status,
        :tasks     => task_status
      }
   end
   
   # Stats for all producers and consumers managed by this controller
   def stats
      @log.debug("Controller: Stats Called")
      res = {
        :producers => producer_stats,
        :consumers => consumer_stats,
        :tasks     => task_stats
      }
   end

   # Add a named queue, would like to deprecate this, but currently gives more control and allows
   # for create of SizedQueue, etc . . . anything that implements a queue like interface can be
   # used here
   def add_q(name, q = nil)
      @log.info("Controller: Adding Queue: #{name}")
      @queues[name] = Queue.new if q.nil?
      @default_q = @queues[name]
   end
   
   # Factory for queues, nice for DRb so there's no confusion as to where the object is instantiated
   def create_q(name)
      @log.info("Controller: Creating Queue: #{name}")
      add_q(name)
   end
   
   def find_q_by_name(name)
      @queues[name]
   end

   # Delete a named queue
   def del_q(name)
      # Should I shut it down first?  Is there a way to tell a queue to stop accepting input,
      # wait until it's empty then go away?  Future enhancement
      @log.info("Controller: Deleting Queue: #{name}")
      @queues.delete(name)
   end
   alias :delete_q :del_q

   # Get queue status
   def q_status
      @log.debug("Controller: Queue Status Called")
      res = {}
      @queues.each do |key, value|
         res[key] = value.status
      end
      res
   end

   # Add a named producer --deprecated in favor of create_producer factory
   def add_producer(name, producer)
      @log.info("Controller: Adding Producer: #{name}")
      @producers[name] = producer
   end
   
   # Start a producer thread pool - please make sure you pass a :name
   # This might be a good place to try an anonymous proc/block passthru(someday)
   def create_producer(classname = nil, config = {})
      classname = Producer if classname.nil?
      # Set some optional defaults
      config[:q] = @default_q if config[:q].nil?
      config[:log] = @log if config[:log].nil?
      @log.info("Controller: Adding Producer: #{config[:name]} of Klass #{classname}")
      return nil if config[:name].nil?
      @producers[config[:name]] = classname.new(config)
   end
   
   # Return handle for producer by name
   def find_producer_by_name(name)
      @producers[name]
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

   # Start a consumer thread pool - please make sure you pass a :name
   # This might be a good place to try an anonymous proc/block passthru(someday)
   def create_consumer(classname = nil, config = {})
      classname = Consumer if classname.nil?
      # Set some optional defaults
      config[:q] = @default_q if config[:q].nil?
      config[:log] = @log if config[:log].nil?
      @log.info("Controller: Adding Consumer: #{config[:name]} of Klass #{classname}")
      return nil if config[:name].nil?
      @consumers[config[:name]] = classname.new(config)
   end
   
   # Return handle for consumer by name
   def find_consumer_by_name(name)
      @consumers[name]
   end

   # Delete a named consumer thread group
   def del_consumer(name)
      @log.info("Controller: Deleting Consumer #{name}")
      @consumers.delete(name)
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

   # Add a named task thread group
   def add_task(name, task)
      @log.info("Controller: Adding Task: #{name}")
      @tasks[name] = task
   end
   
   # Start a task thread pool - please make sure you pass a :name
   # This might be a good place to try an anonymous proc/block passthru(someday)
   def create_task(classname = nil, config = {})
      classname = Task if classname.nil?
      # Set some optional defaults
      config[:q] = @default_q if config[:q].nil?
      config[:log] = @log if config[:log].nil?
      @log.info("Controller: Adding Task: #{config[:name]} of Klass #{classname}")
      return nil if config[:name].nil?
      @tasks[config[:name]] = classname.new(config)
   end
   
   # Return handle for task by name
   def find_task_by_name(name)
      @tasks[name]
   end
   
   # Delete a named task thread group
   def del_task(name)
      @log.info("Controller: Deleting Task #{name}")
      @tasks.delete(name)
   end
   
   # Shutdown named consumer group nice (empties queue first, might take a while)
   def shutdown_task(name)
      @log.info("Controller: Shutting Down Task: #{name}")
      @tasks[name].shutdown
   end
   
   # Shutdown all task groups (empties q(if q used) first, might take a while)
   def shutdown_tasks
      @log.info("Controller: Shutting Down All Tasks")
      @tasks.each do |key, task|
         task.shutdown
      end
   end
   
   # Kill named task immediately, not nice
   def kill_task(name)
      @log.info("Controller: Killing Task: #{name}")
      @tasks[name].kill
   end
   
   # Kill all tasks now, not nice
   def kill_tasks
      @log.info("Controller: Killing Tasks")
      @tasks.each do |key, task|
         task.kill
      end
   end
   
   # Get status of all tasks
   def task_status
      @log.debug("Controller: Task Status Called")
      res = {}
      @tasks.each do |key, value|
        res[key] = value.status
      end
      res
   end
   
   # Get status of all tasks
   def task_stats
      @log.debug("Controller: Task Stats Called")
      res = {}
      @tasks.each do |key, value|
         res[key] = value.stats
      end
      res
   end
   
   # Shutdown all producers, consumers, and tasks managed by this controller
   def shutdown
      @log.info("Controller: Shutdown Called")
      shutdown_producers
      shutdown_consumers
      shutdown_tasks
   end

   # Kill all producers and consumers immediately, not nice
   def kill
      @log.info("Controller: Kill Called")
      kill_producers
      kill_consumers
      kill_tasks
   end

end
