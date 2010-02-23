#!/usr/bin/env ruby

require "snmp"

module Pollable
   attr_accessor :manager
   def establish_snmp
      if @manager.nil?
         community = read_string if read_string.exists?
         @manager = SNMP::Manager.new(:Host => ip_address, :Community => community)
      end
   end

   def get_value(mib)
      establish_snmp if @manager.nil?
      begin
         @manager.get_value(mib)
      rescue SNMP::RequestTimeout
         SNMP::Response.new(0, [])
      end
   end

   def get_bulk(nonrepeaters, maxrepeaters, mibs)
      establish_snmp if @manager.nil?
      begin
         @manager.get_bulk(nonrepeaters, maxrepeaters, mibs)
      rescue SNMP::RequestTimeout
         SNMP::Response.new(0, [])
      end
   end

   def rate_calc(new_counter, old_counter, new_timestamp, old_timestamp)
      new_counter = 0 if new_counter.nil?
      old_counter = 0 if old_counter.nil?
      if (new_timestamp.to_i - old_timestamp.to_i) > 0 and old_counter > 0
         counter_delta(new_counter, old_counter) / (new_timestamp.to_i - old_timestamp.to_i)
      else 
         0
      end
   end

   def counter_delta(new_counter, old_counter)
      new_counter = 0 if new_counter.nil?
      old_counter = 0 if old_counter.nil?
      if new_counter > old_counter and old_counter > 0
         new_counter - old_counter
      else
         0
      end
   end
end