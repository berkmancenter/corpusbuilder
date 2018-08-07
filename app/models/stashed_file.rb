class StashedFile < ApplicationRecord
  mount_uploader :attachment, SimpleFileUploader
end
