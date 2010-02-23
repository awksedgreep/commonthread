# This is where you set up all your relationships.  Generally the rule is to
# create one per controller.
#
# Example startup:
#   # Start a thread safe logger q
#   log = Log.new
#   log.application = "CommonThreads Example"
#   # Start a single consumer thread to eat the log q, arguments are
#   # queue name(log in this case), and object handle for logging(STDERR)
#   # object handle must implement IO method "puts", see log.rb for db
#   # logging example
#   logconsumer = LogConsumer.new(log, STDERR)
#
#   # Logging is very flexible, but requires three or more steps to set up
#   # bear in mind that it is optional, $log will be used by default if you
#   # don't want to pass the log into every object
#
#   # Start your controller here.  The controller's primary purpose is to manage a set
#   # of Producers and Consumers and ease administration.
#   main = Controller.new(:log => log)
#
#   # Create the queue, sized queue in this case
#	 q = SizedQueue.new(100)
#
#   # Create the producers, note the log handle is the queue, not the object handle
#   # the block is optional and wouldn't be used if you specify your own producers with
#   # their own event_loop, if you pass the block it executes the block instead
#   p = Producer.new(:num_threads => 10, :q => q, :log => log) { every 10.seconds; @q.enq Time.now }
#
#   # Create the consumers, same basic methods as the producer, but bear in mind
#   # producers collect and add items to queues(usually), and consumers read from the
#   # queue(optionally)
#   c = Consumer.new(:num_threads => 10, :q => q, :log => log) { puts @q.deq }
#
#   # Now we register everything with the controller, all items have a name for easy access
#   # The name for each object of the same type has to be unique, but the following is acceptable
#   # if you only have one of each.
#   main.add_q('Main', q)
#   main.add_producer('Main', p)
#   main.add_consumer('Main', c)
#
#   # You're in business
#
####################################################################################
# Add your startup below this line
mc = MasterController.new
cm_q = mc.add_q('CmQ')
cmts_q = mc.add_q('CmtsQ')
cm_producer = CmProducer.new(:q => cm_q, :num_threads => 1)
mc.add_producer('CmProducer', cm_producer)
cmts_producer = CmtsProducer.new(:q => cmts_q, :num_threads => 1)
mc.add_producer('CmtsProducer', cmts_producer)
cm_consumer = CmConsumer.new(:q => cm_q, :num_threads => 300)
mc.add_consumer('CmConsumer', cm_consumer)
cmts_consumer = CmtsConsumer.new(:q => cmts_q, :num_threads => 10)
mc.add_consumer('CmtsConsumer', cmts_consumer)
