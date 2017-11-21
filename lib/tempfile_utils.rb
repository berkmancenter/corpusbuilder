class TempfileUtils
  def self.next_path(part)
    f = Tempfile.new(part)
    res = f.path
    f.close
    res
  end
end
