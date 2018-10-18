class ScriptList
  ALL = [
    [ 'latin', 'Latin' ],
    [ 'arabic', 'Arabic' ],
    [ 'syriac', 'Syriac' ],
    [ 'hebrew', 'Hebrew' ]
  ].map { |k, v| OpenStruct.new(code: k, name: v).freeze }

  def self.find(code)
    codes = code.is_a?(Array) ? code : [ code ]

    ALL.select { |script| codes.any? { |_code| script.code == _code } }
  end
end
