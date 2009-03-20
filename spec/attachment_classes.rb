# Our role here is to allow the tester to create a single object type, instead of being
# concerned about what type of attachment plugin or gem is running. If we find the Paperclip
# const defined, we'll assume paperclip is present and provide those methods accordingly.
class ScribdDocumentProxy
  
  @@paperclip = nil
  
  def self.init
    if @@paperclip.nil?
      @@paperclip  = Object.const_defined?(:Paperclip)
    end
    
    require File.join(File.dirname(__FILE__), 
      @@paperclip ? 'fixtures/paperclip_scribd_attachment' : 'fixtures/attachment_fu_scribd_attachment')
  end
  
  def initialize(document='test.pdf', mime_type='application/pdf')
    self.class.init if @@paperclip.nil?
      
    if @@paperclip
      options = {:document => upload_file(document, mime_type)}
      doc = PaperclipScribdAttachment.new(options)
    else
      options = {:uploaded_data => upload_file(document, mime_type)}
      doc = AttachmentFuScribdAttachment.new(options)
    end
    
    doc.save!
    @subject = doc
  end
  
  def method_missing(name, *args)
    @subject.send(name, *args)
  end

  def scribd_id
    @@paperclip ? @subject.document_scribd_id : @subject.scribd_id
  end
  
  def scribdable?(document=nil)
    @@paperclip ? @subject.scribdable?(:document) : @subject.scribdable?
  end

  def thumbnail_url(document=nil)
    @@paperclip ? @subject.thumbnail_url(:document) : @subject.thumbnail_url
  end
  
  def conversion_error?(document=nil)
    @@paperclip ? @subject.conversion_error?(:document) : @subject.conversion_error?
  end
  
  def upload_file(file, mime_type)
    file = File.join(File.dirname(__FILE__), "fixtures/#{file}")
    ActionController::TestUploadedFile.new(file, mime_type)
  end

end
