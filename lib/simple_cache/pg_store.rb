require "micro_sql"

class SimpleCache::PgStore
  Marshal = ::SimpleCache::Marshal
  
  TABLE_NAME = "simple_cache2"

  attr :path

  def initialize(url)
    expect! url => String
    @db = MicroSql.create(url)
  end
  
  def table
    @db.key_value_table(TABLE_NAME)
  end

  def fetch(key, &block)
    value = table[key]
    return Marshal.unmarshal(value) if value
    return yield(self, key) if block
    nil
  end

  def store(key, value, ttl = nil)
    table.update(key, Marshal.marshal(value), ttl)
    value
  end

  def clear
    return unless @db.tables.include?(table.table_name)
    @db.ask "DELETE FROM #{table.table_name}"
  end
end
