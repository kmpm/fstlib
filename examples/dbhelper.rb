require "sqlite3"
require "fstlib"

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

class DbHelper
  attr_accessor :db
  def init_db
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
   
     @db = SQLite3::Database.new("test.sq3")
     @db.type_translation = true
     
     @db.execute_batch(sql)
     @db
  end


  def insert_value(table, id, value)
    @db.execute("INSERT OR REPLACE INTO " + table + " values(?, ?)", id, value )
  end

  def get_payload(table, from, to)
    payload=[]
    @db.execute("SELECT id, value FROM " + table + " WHERE id>=? AND id<=?", from, to) do |row|
      p row
      payload << row[1]
    end
    payload
  end

end



if __FILE__ == $0
  # TODO Generated stub
end