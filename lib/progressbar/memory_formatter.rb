class MemoryFormatter
  def initialize(progress)
    @progress = progress
  end

  def matches?(value)
    value.to_s =~ /:memory/
  end

  def format(value)
    value.gsub(/:memory/, (`ps -o rss= -p #{$$}`.to_f / 1000).to_s)
  end
end
