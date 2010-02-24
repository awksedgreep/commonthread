#!/usr/bin/env ruby

require 'erb'
require 'pp'

class Generator
   
   def generate(basedir, generator, classname)
      output_file = basedir.to_s << '/' << classname.downcase.to_s << '.rb'
      generator_file = File.dirname(File.expand_path(__FILE__)) << '/../../generators/' << generator.to_s.downcase << '.rhtml'
      puts generator_file
      if FileTest.exists?(generator_file)
         puts "Classname: #{classname}\nOutput File: #{output_file}\nGenerator File: #{generator_file}\nGenerator: #{generator}"
         output = File.open(output_file, 'w')
         contents = File.open(generator_file).read
         tpl = ERB.new(contents)
         pp tpl
         tpl_res = tpl.result(binding)
         puts tpl_res
         output.puts tpl_res.to_s
         output.close
      end
   end
   
   def initialize(type, classname)
      case type
         when 'producer' then generate('app/producers', 'producer', classname)
         when 'consumer' then generate('app/consumers', 'consumer', classname)
         when 'logger' then generate('app/loggers', 'logger', classname)
         when 'model' then generate('app/models', 'model', classname)
         when 'startup' then generate('app/startup', 'startup', classname)
         when 'task' then generate('app/tasks', 'task', classname)
         when 'scaffold' then
            generate('app/producers', 'producer', classname)
            generate('app/consumers', 'consumer', classname)
            generate('app/tasks', 'task', classname)
            generate('app/loggers', 'logger', classname)
            generate('app/models', 'model', classname)
            generate('app/startup', 'startup', classname)
         else
            puts 'Did not understand your request.'
            usage
            exit(1)
      end
   end

   def usage
      puts 'generate (producer|consumer|task|logger|model|startup|scaffold) classname'
   end
end
