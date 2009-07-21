#!/usr/bin/ruby
require "fstlib"
require "eventmachine"
require "mq"
require "sqlite3"


class EasyIPHandler < EventMachine::Connection
  
  attr_accessor :queue
  attr_accessor :db
  
  def get_table(operand)
    case operand
      when EasyIP::Operand::FLAG_WORD
        table='flags'
      when EasyIP::Operand::INPUT_WORD
        table='inputs'
      when EasyIP::Operand::OUTPUT_WORD
        table='outputs'
      when EasyIP::Operand::REGISTERS
        table='registers'
      when EasyIP::Operand::STRING
        table='strings' 
   end
   return table
  end
  
  def receive_data data
    req=EasyIP::Header.new(data)
    
    resp = EasyIP::Header.new
    resp.counter=req.counter
    resp.flags = EasyIP::Flags::RESP  
    
    table=get_table(req.send_type)
    
    if req.send_type != EasyIP::Operand::EMPTY
      values = req.payload
      id=0
      values.each do |value|
        db.execute("INSERT OR REPLACE INTO " + table + " values(?, ?)", id + req.send_offset, value )
        id+=1
      end  
    end
    
    
    
    if req.req_type != EasyIP::Operand::EMPTY
      resp.req_type = req.req_type
      resp.req_offset_server = req.req_offset_server
      resp.req_offset_client = req.req_offset_client
      resp.req_size = req.req_size
      table = get_table(req.req_type)
      id=0
      payload=[]
      db.execute("SELECT id, value FROM " + table + " WHERE id>=?", req.req_offset_server, req.req_offset_server+req.req_size) do |row|
        p row
        payload << row[1]
      end
      p payload
      resp.payload = payload
      puts resp.inspect
    end
    #puts req.inspect    
    #puts resp.unpack("H*")
    
    send_data resp
    @queue.publish(req.inspect)
    
  end
  
  
end


if __FILE__ == $0
  # TODO Generated stub
  host = ''
  port = 995
 
  sql = <<SQL
    CREATE TABLE IF NOT EXISTS registers (
      id INTEGER,
      value INTEGER,
      PRIMARY KEY(id ASC)
    );
    
    CREATE TABLE IF NOT EXISTS inputs (
      id INTEGER,
      value INTEGER,
      PRIMARY KEY(id ASC)
    );
    
    CREATE TABLE IF NOT EXISTS outputs (
      id INTEGER,
      value INTEGER,
      PRIMARY KEY(id ASC)
    );
    
    CREATE TABLE IF NOT EXISTS flags (
      id INTEGER,
      value INTEGER,
      PRIMARY KEY(id ASC)
    );
    
    CREATE TABLE IF NOT EXISTS strings (
      id INTEGER,
      value TEXT,
      PRIMARY KEY(id ASC)
    );
SQL
   
   db = SQLite3::Database.new("test.sq3")
   db.type_translation = true
   
   db.execute_batch(sql)
  
  EventMachine::run do
    amq = MQ.new
    queue = amq.queue('fst')
    EventMachine::open_datagram_socket host, port, EasyIPHandler do | handler |
        handler.queue = queue
        handler.db=db
    end
  end
 
end




