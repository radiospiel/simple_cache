# A simplistic Sqlite database interface
class SimpleCache::SqliteDatabase
  def initialize(path)
    require "sqlite3"

    FileUtils.mkdir_p File.dirname(@path)

    @impl = SQLite3::Database.new(path)
    @prepared_queries = {}
    ask "PRAGMA synchronous = OFF"
  end

  def exec(sql, *args)
    query = @prepared_queries[sql] ||= @impl.prepare(sql)
    query.execute!(*args)
  end

  def ask(sql, *args)
    exec(sql, *args).first
  end
end

class SimpleCache::SqliteStore < SimpleCache::SqliteDatabase
  Marshal = ::SimpleCache::Marshal
  
  TABLE_NAME = "simple_cache"

  def self.base_dir
    if RUBY_PLATFORM.downcase.include?("darwin")
      "#{Dir.home}/Library/Cache"
    else
      "#{Dir.home}/cache"
    end
  end

  attr :path

  def initialize(name) 
    @path = "#{SimpleCache::SqliteStore.base_dir}/#{name}/simple_cache.sqlite3" 
    super @path

    begin
      ask("SELECT 1 FROM #{TABLE_NAME} LIMIT 1")
    rescue SQLite3::SQLException
      ask("CREATE TABLE #{TABLE_NAME}(uid INTEGER PRIMARY KEY, value TEXT, ttl INTEGER NOT NULL)")
    end
  end

  def fetch(key, &block)
    value, ttl = ask("SELECT value, ttl FROM #{TABLE_NAME} WHERE uid=?", Marshal.uid(key))
    if ttl && (ttl == 0 || ttl > Time.now.to_i)
      Marshal.unmarshal(value) 
    elsif block_given?
      yield self, key
    end
  end

  def store(key, value, ttl = nil)
    unless value.nil?
      ask("REPLACE INTO #{TABLE_NAME}(uid, value, ttl) VALUES(?,?,?)", 
            Marshal.uid(key), Marshal.marshal(value), ttl ? ttl + Time.now.to_i : 0)
    else
      ask("DELETE FROM #{TABLE_NAME} WHERE uid=?", Marshal.uid(key))
    end

    value
  end

  def clear
    ask "DELETE FROM #{TABLE_NAME}"
  end
end
