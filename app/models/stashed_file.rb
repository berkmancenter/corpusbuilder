# Having this class / model allows us to defer execution of certain
# actions that take files as parameters.
#
# The regular Ruby's File class is not serializable so no ActiveJob backend
# can handle them.
class StashedFile < ApplicationRecord
  mount_uploader :attachment, SimpleFileUploader
end
