#!/usr/bin/env ruby

#Thread.abort_on_exception = true

# Import Java's AtomicBoolean for thread-safe shutdown signaling
require 'java'
java_import 'java.util.concurrent.atomic.AtomicBoolean'

# Producers generally grab stuff from a model or service and put them in
# a queue
class Producer

   DefaultConfig = { :q => nil, :num_threads => 10, :loop_until => forever }
   attr_reader :q, :threads, :num_threads, :jobs_processed, :config, :loop_until

   # standard config options are :q, :num_threads (default => 10), :log (default => $log)
   # pass a block in to override the standard event_loop
   def initialize(config = {}, &block)
      @shutdown_flag = AtomicBoolean.new(false)  # Thread-safe shutdown flag
      @config = DefaultConfig.merge(config)
      @num_threads = @config[:num_threads]
      @q = @config[:q]
      @loop_until = @config[:loop_until]
      @log = @config[:log]
      @event_loop_block = block  # Capture the block if provided
      if @log.nil?
         @log = Log.new(:application => "CommonThread", :log_level => 1)
         @logconsumer = LogConsumer.new(@log, STDOUT)
      end
      @jobs_processed = Counter.new
      @threads = []
      start_threads(@config[:num_threads])
      self
   end
   alias start initialize

   # Get thread status, not to be confused with stats
   def status
      @log.debug self.class.to_s + ": Status Called"
      res = []
      @threads.each do |thread|
         lres = thread.status
         lres = "dead" if lres == false
         res << lres
      end
      res
   end
   
   # Get thread stats, number of jobs processed or event_loops iterated
   def stats
      @log.debug self.class.to_s + ": Stats Called"
      @jobs_processed.count
   end

   # shutdown waits for threads to complete current event loop
   def shutdown
      @log.info self.class.to_s + ": Shutting Down"
      @shutdown_flag.set(true)  # Atomically set shutdown flag (visible to all threads)
      
      # Push sentinel values to wake up threads blocked on queue operations
      # One sentinel per thread ensures all threads wake up
      if @q.is_a?(Queue)
         @num_threads.times { @q.enq(:shutdown) }
      end
      
      # Wake up any sleeping threads
      @threads.compact.each do |thread|
         next unless thread.is_a?(Thread)
         begin
           thread.wakeup if thread.alive?  # Wake regardless of status
         rescue ThreadError => e
           @log.debug "Could not wakeup thread: #{e.message}"
         end
      end
      
      # Wait for threads to actually terminate
      @threads.compact.each do |thread|
         next unless thread.is_a?(Thread)
         thread.join(2.0) if thread.alive?  # Wait up to 2 seconds per thread
      end
   end
   alias stop shutdown
   
   # restart threads after shutdown -- DOES NOT SHUTDOWN FOR YOU, you need to do that and wait for threads to finish processing
   def restart
      return true if !@shutdown_flag.get
      @log.info self.class.to_s + ": Restarting after shutdown"
      @shutdown_flag.set(false)
      start_threads(@num_threads)
   end
   
   # add threads to the pool
   def add(number_of_threads_to_add)
      start_threads(number_of_threads_to_add + @num_threads, @num_threads)
      @num_threads += number_of_threads_to_add
   end
   
   # reduce the number of threads
   def remove(number_of_threads_to_remove)
      (@num_threads - 1).downto(@num_threads - number_of_threads_to_remove) do |tid|
         @threads[tid][:shutdown] = true
      end
      @num_threads -= number_of_threads_to_remove
   end

   # killall kills the threads immediately
   def killall
      @log.info self.class.to_s + ": Killing Threads"
      shutdown
      @threads.each do |thread| thread.kill end
      status
   end
   alias kill killall
   
   # start x threads
   def start_threads(start_num_threads = @num_threads, start_index = 0)
      start_index.upto(start_num_threads - 1) do |tid|
         create_thread(tid)
      end
   end
   
   # Create a thread for this thread group
   def create_thread(tid)
      @log.debug self.class.to_s + ": Creating thread " + tid.to_s
      @threads[tid] = Thread.new(tid) do |tid|
         Thread.current[:tid] = tid
         until @shutdown_flag.get  # Atomically read shutdown flag (guaranteed visibility)
            error = false
            result = nil
            begin
               result = event_loop
            rescue Exception => e
               error = true
               @log.error e.message
               @log.error e.backtrace.join("\n")
            end
            # Break if event_loop returned shutdown sentinel
            break if result == :shutdown
            @jobs_processed.iterate unless error
            @shutdown_flag.set(true) if Time.now >= @loop_until
         end
      end
   end
   
   def refresh_threads
      refreshed = 0
      @threads.each_with_index do |thread, index|
         if thread.status == false
            @log.warn self.class.to_s + ": Thread #{index} appears to be dead . . refreshing"
            create_thread(index)
            refreshed += 1
         end
      end
      @log.debug "Refreshed #{refreshed} threads."
   end

   # Default event_loop for the thread, overload this
   def event_loop
      # If a block was provided, execute it
      # Use instance_eval to run in this object's context
      if @event_loop_block
         instance_eval(&@event_loop_block)
      elsif q.class == Queue
         every 5.seconds
         res = Time.now
         @log.debug self.class.to_s + ": Queueing " + res.class.to_s
         q.enq res
      else
         every 5.seconds
         print Thread.current[:tid].to_s << " => " << Time.now.to_s << "\n"
      end
   end
end
