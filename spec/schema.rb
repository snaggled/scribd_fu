ActiveRecord::Schema.define(:version => 0) do
  
  create_table :paperclip_scribd_attachments, :force => true do |t|
    t.string    :document_file_name
    t.string    :document_content_type
    t.integer   :document_file_size
    t.datetime  :document_updated_at
    t.integer   :document_scribd_id
    t.string    :document_scribd_access_key
  end
  
  create_table :attachment_fu_scribd_attachments, :force => true do |t|
    t.integer   :size
    t.string    :content_type
    t.string    :filename
    t.integer   :scribd_id
    t.string    :scribd_access_key
  end
  
end
