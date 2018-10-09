class ScriptList
  ALL = [
    [ 'latin', 'Latin' ],
    [ 'arabic', 'Arabic' ],
    [ 'syriac', 'Syriac' ],
    [ 'hebrew', 'Hebrew' ]
  ].map { |k, v| OpenStruct.new(code: k, name: v).freeze }
end
