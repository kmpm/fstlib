#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__) 
require "rubygems"
require "eventmachine"
require "mq"
require 'benchmark'
require 'fstlib'
require 'dbhelper'

def unserialize data
  autoload_missing_constants do
    Marshal.load data
  end
end

def autoload_missing_constants
  yield
rescue ArgumentError => error
  lazy_load ||= Hash.new {|hash, hash_key| hash[hash_key] = true; false}
  if error.to_s[/undefined class|referred/] && !lazy_load[ Kernel.const_get(error.to_s.split.last).methods]
    retry
  else
    raise error
  end
end


if __FILE__ == $0
  # TODO Generated stub
  host = ''
  port = 995
 # Shutdown AMQP gracefully so messages are published
  #Signal.trap('INT') { AMQP.stop{ EM.stop } }
  #Signal.trap('TERM'){ AMQP.stop{ EM.stop } }
  
  
  
  
  
  
  EventMachine::run do
    
   dbhelper = DbHelper.new
   dbhelper.init_db
    
    
    amqp = AMQP.connect(:user=>'someuser', :pass=>'somepass', :host=>'10.100.0.9', :port=>5672)
    puts 'connected'
    amq = MQ.new(amqp)
    queue = amq.queue('festo.icomming.import').bind(amq.topic('festo'), :key=>'packet.incomming')
    puts 'bound to queue'
    queue.subscribe(:ack=>true) do | headers, data |
      req = unserialize (data)
      table=get_table(req.send_type)
      puts 'saving'
      if req.send_type != EasyIP::Operand::EMPTY
        values = req.payload
        id=0
        values.each do |value|
          dbhelper.insert_value(table, id + req.send_offset, value)
          id+=1
        end
        puts 'saved packet %d ' % req.counter
      end
      headers.ack
    end
  end
 
end




