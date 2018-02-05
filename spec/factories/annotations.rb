FactoryGirl.define do
  factory :annotation do
    content "Lorem ipsum dolor sit amet"
    editor_id ""
    areas [ ]
    payload {}
    status Annotation.statuses[:regular]
    mode Annotation.modes[:comment]
  end
end
