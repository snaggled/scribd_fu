class PaperclipScribdAttachment < ActiveRecord::Base
  has_attached_file :document
  has_scribdable_attachment :document
  validates_attachment_scribdability :document
end
