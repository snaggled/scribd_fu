class AttachmentFuScribdAttachment < ActiveRecord::Base
  has_attachment :storage => :file_system
  acts_as_scribd_document
  validates_as_scribd_document
end