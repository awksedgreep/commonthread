#!/usr/bin/env ruby

### DO NOT EDIT ###

# Required modules
require 'rubygems'
require 'commonthread_env'

# Include files in this order
dirs = ["config", "app/apis", "app/models", "app/loggers",
        "app/producers", "app/consumers", "app/tasks"]

dirs.each do |dir|
   Dir[dir + "/*.rb"].each do |file|
      #puts "loading #{file}"
      load "#{file}"
   end
end
