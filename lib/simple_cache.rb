require "uri"
require "logger"
require "sqlite3"
require "base64"
require "digest/md5"

class SimpleCache
  module Marshal
    def self.uid(key)
      md5 = Digest::MD5.hexdigest(key)
      md5.unpack("LL").inject { |a,b| (a << 31) + b }
    end

    def self.unmarshal(marshalled)
      ::Marshal.load Base64.decode64(marshalled) if marshalled
    end

    def self.marshal(value)
      Base64.encode64 ::Marshal.dump(value)
    end
  end

  TABLE_NAME = "simple_cache"
  
  def self.base_dir
    if RUBY_PLATFORM.downcase.include?("darwin")
      "#{Dir.home}/Library/Cache"
    else
      "#{Dir.home}/cache"
    end
  end
  
  extend Forwardable
  delegate :ask => :@db
  delegate [ :uid, :marshal, :unmarshal ] => :@marshaller
  
  attr :path
  
  def initialize(name)
    @path = "#{SimpleCache.base_dir}/#{name}/simple_cache.sqlite3" 
    FileUtils.mkdir_p File.dirname(@path)

    @db = Database.new(@path)
    @marshaller = SimpleCache::Marshal
    
    begin
      ask("SELECT 1 FROM #{TABLE_NAME} LIMIT 1")
    rescue SQLite3::SQLException
      ask("CREATE TABLE #{TABLE_NAME}(uid INTEGER PRIMARY KEY, value TEXT, ttl INTEGER NOT NULL)")
    end
  end

  def fetch(key, &block)
    value, ttl = ask("SELECT value, ttl FROM #{TABLE_NAME} WHERE uid=?", uid(key))
    if ttl && (ttl == 0 || ttl > Time.now.to_i)
      unmarshal(value) 
    elsif block_given?
      yield self, key
    end
  end

  def store(key, value, ttl = nil)
    unless value.nil?
      ask("REPLACE INTO #{TABLE_NAME}(uid, value, ttl) VALUES(?,?,?)", 
            uid(key), marshal(value), ttl ? ttl + Time.now.to_i : 0)
    else
      ask("DELETE FROM #{TABLE_NAME} WHERE uid=?", uid(key))
    end

    value
  end

  def clear
    ask "DELETE FROM #{TABLE_NAME}"
  end
  
  def expire(key, ttl)
    ttl = ttl ? ttl + Time.now.to_i : 0
    ask("UPDATE #{TABLE_NAME} SET ttl=? WHERE uid=?", ttl, uid(key))
  end

  def cached(key, ttl = nil, &block)
    fetch(key) do
      set(key, yield, ttl)
    end
  end

  # redis-like aliases
  
  alias :get :fetch
  alias :set :store
  alias :flush_db :clear

  # A simplistic Sqlite interface
  class Database
    def initialize(path)
      @impl = SQLite3::Database.new(path)
      @prepared_queries = {}
      ask "PRAGMA synchronous = OFF"
    end

    def ask(sql, *args)
      results = execute sql, *args
      format_results_for_ask(results)
    end

    def execute(sql, *args)
      query = @prepared_queries[sql] ||= @impl.prepare(sql)

      results = query.execute!(*args)
      case sql
      when /^\s*INSERT/i then @impl.last_insert_row_id
      when /^\s*UPDATE/i then @impl.changes
      when /^\s*DELETE/i then @impl.changes
      else                    results
      end
    end

    private

    def format_results_for_ask(results)
      return results unless results.is_a?(Array)

      results = results.first

      return results unless results.is_a?(Array)
      return results if results.length != 1

      results.first
    end
  end
end
