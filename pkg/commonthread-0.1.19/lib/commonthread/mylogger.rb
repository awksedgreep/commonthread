#!/usr/bin/env ruby

require 'mysql'

class MyLogger
   attr_accessor :conn, :table

   def initialize
      @table = 'log'
   end

   def puts(entry)
      if not @conn.nil? and not entry.nil?
         @conn.query("INSERT INTO #{@table} (application, level, message, created_at) VALUES ('#{entry.application}', #{entry.level}, '#{entry.message}', from_unixtime(#{entry.ts.to_i}))")
      end
   end
   alias write puts
end