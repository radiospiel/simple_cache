require "micro_sql"

class SimpleCache::PgStore
  Marshal = ::SimpleCache::Marshal
  
  TABLE_NAME = "simple_cache"

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
    return value if value
    return yield(self, key) if block
    nil
  end

  def store(key, value, ttl = nil)
    table.update(key, value, ttl)
    value
  end

  def clear
    return unless @db.tables.include?(TABLE_NAME)
    @db.ask "DELETE FROM #{TABLE_NAME}"
  end
end
