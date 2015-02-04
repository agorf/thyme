module Enumerable
  def map_with_index(&block)
    each_with_index.map(&block)
  end
end

class String
  def camelize
    if self['_']
      split('_').map_with_index {|s, i| i == 0 ? s : s.capitalize }.join
    else
      self.downcase
    end
  end
end

class Hash
  def camelize_keys
    Hash[map {|k, v| [k.to_s.camelize, v] }]
  end
end
