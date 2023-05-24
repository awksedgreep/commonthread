#!/usr/bin/env ruby

### DO NOT EDIT ###

# Controller registry
$controllers = []

# Required modules
#require 'rubygems'
#require 'commonthread'

# Include files in this order
dirs = ["config", "app/controllers", "app/apis", "app/models", "app/loggers",
        "app/producers", "app/consumers"]

dirs.each do |dir|
   Dir[dir + "/*.rb"].each do |file|
      #puts "loading #{file}"
      load "#{file}"
   end
end
