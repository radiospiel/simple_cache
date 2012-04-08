require "base64"
require "digest/md5"

module SimpleCache::Marshal
  extend self
  
  def uid(key)
    md5 = Digest::MD5.hexdigest(key)
    md5.unpack("LL").inject { |a,b| (a << 31) + b }
  end

  def unmarshal(marshalled)
    ::Marshal.load Base64.decode64(marshalled) if marshalled
  end

  def marshal(value)
    Base64.encode64 ::Marshal.dump(value)
  end
end
