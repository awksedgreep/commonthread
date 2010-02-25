#!/usr/bin/env ruby

#Thread.abort_on_exception = true

# Producers generally grab stuff from a model or service and put them in
# a queue
class Producer

   DefaultConfig = { :q => nil, :num_threads => 10 }
   attr_reader :q, :threads, :num_threads, :jobs_processed, :config

   # standard config options are :q, :num_threads (default => 10), :log (default => $log)
   # pass a block in to override the standard event_loop
   def initialize(config = {})
      @shutdown = false
      @config = DefaultConfig.merge(config)
      @num_threads = @config[:num_threads]
      @q = @config[:q]
      @log = @config[:log]
      if @log.nil?
         @log = Log.new(:application => "CommonThread", :log_level => 1)
         @logconsumer = LogConsumer.new(@log, STDOUT)
      end
      @jobs_processed = Counter.new
      @threads = []
      1.upto(@num_threads) do |tid|
         @threads << Thread.new(tid) do |tid|
            Thread.current['tid'] = tid
            while not @shutdown
               if block_given?
                  yield
               else
                  begin
                     event_loop
                  rescue Exception => e  
                     puts e.message  
                     puts e.backtrace.inspect
                  end
               end
               @jobs_processed.iterate
            end
         end
      end
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
      @shutdown = true
   end
   alias stop shutdown

   # killall kills the threads immediately
   def killall
      @log.info self.class.to_s + ": Killing Threads"
      @shutdown = true
      @threads.each do |thread| thread.kill end
      status
   end
   alias kill killall

   # Default event_loop for the thread, overload this
   def event_loop
      if q.class == Queue
         every 5.seconds
         res = Time.now
         @log.debug self.class.to_s + ": Queueing " + res.class.to_s
         q.enq res
      else
         every 5.seconds
         print Thread.current['tid'].to_s << " => " << Time.now.to_s << "\n"
      end
   end
end
