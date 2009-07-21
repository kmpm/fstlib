#!/usr/bin/ruby
require "rubygems"
require "eventmachine"
require "mq"



if __FILE__ == $0
  # TODO Generated stub
  host = ''
  port = 995
 
  EventMachine::run do
    amq = MQ.new
    queue = amq.queue('fst')
    queue.subscribe do | data |
      puts data
    end
  end
 
end




