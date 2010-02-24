#!/usr/bin/env ruby

DEBUG    = 0
INFO     = 1
WARN     = 2
NOTICE   = 3
ERROR    = 4
FATAL    = 5
UNKNOWN  = 6

# Log entry
class LogEntry
   attr_accessor :application, :level, :message, :ts
   ERROR_LEVELS = ['DEBUG', 'INFO', 'WARN', 'NOTICE', 'ERROR', 'FATAL', 'UNKNOWN']
   def to_s
      "#{@ts.to_s} | #{@application.to_s} | #{ERROR_LEVELS[@level]} | #{@message.to_s}"
   end
end

# Thread safe Queue for logging
class Log < Queue

   DefaultConfig = { :log_level => 0, :application => "Unknown" }
   attr_accessor :log_level, :application, :config

   def initialize(config = {})
      @config = DefaultConfig.merge(config)
      @log_level = @config[:log_level]
      @application = @config[:application]
      super()
   end

   def add(level, message, ts)
      entry = LogEntry.new
      entry.application = @application
      entry.level = level
      entry.message = message
      entry.ts = ts
      enq entry
   end

   def debug(message)
      add(DEBUG, message, Time.now) if @log_level == DEBUG
   end

   def info(message)
      add(INFO, message, Time.now) if @log_level <= INFO
   end

   def warn(message)
      add(WARN, message, Time.now) if @log_level <= WARN
   end
   alias warning warn

   def notice(message)
      add(NOTICE, message, Time.now) if @log_level <= NOTICE
   end
   alias alert notice

   def error(message)
      add(ERROR, message, Time.now) if @log_level <= ERROR
   end
   alias err error

   def fatal(message)
      add(FATAL, message, Time.now) if @log_level <= FATAL
   end
   alias emerg fatal
   alias crit fatal
   alias critical fatal

   def unknown(message)
      add(UNKNOWN, message, Time.now)
   end
end

# Thread for consuming the Queue and outputting to a medium
# a medium is defined as any class with a puts method
# Will rewrite later to use new "Consumer" base class
class LogConsumer
   attr_accessor :q, :medium, :thread, :shutdown
   def initialize(q, medium)
      @medium = medium
      @shutdown = false
      @thread = Thread.new(q, medium) do |q, medium|
         while not @shutdown
            if q.empty?
               sleep 0.1
            else
               entry = q.deq(true)
               medium.puts entry if not entry.nil?
            end
         end
      end
   end
end
