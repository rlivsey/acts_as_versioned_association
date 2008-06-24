ActiveRecord::Schema.define(:version => 0) do

  #### Tables for AAV tests

  create_table :pages, :force => true do |t|
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :updated_on, :datetime
    t.column :author_id, :integer
    t.column :revisor_id, :integer
  end

  create_table :page_versions, :force => true do |t|
    t.column :page_id, :integer
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :updated_on, :datetime
    t.column :author_id, :integer
    t.column :revisor_id, :integer
  end
  
  create_table :authors, :force => true do |t|
    t.column :page_id, :integer
    t.column :name, :string
  end
  
  create_table :locked_pages, :force => true do |t|
    t.column :lock_version, :integer
    t.column :title, :string, :limit => 255
    t.column :type, :string, :limit => 255
  end

  create_table :locked_pages_revisions, :force => true do |t|
    t.column :page_id, :integer
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :version_type, :string, :limit => 255
    t.column :updated_at, :datetime
  end

  create_table :widgets, :force => true do |t|
    t.column :name, :string, :limit => 50
    t.column :foo, :string
    t.column :version, :integer
    t.column :updated_at, :datetime
  end

  create_table :widget_versions, :force => true do |t|
    t.column :widget_id, :integer
    t.column :name, :string, :limit => 50
    t.column :version, :integer
    t.column :updated_at, :datetime
  end
  
  #### Tables for AAVA tests
  
  create_table :articles, :force => true do |t|
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :updated_on, :datetime
    t.column :created_on, :datetime    
    t.column :author_id, :integer
    t.column :revisor_id, :integer
  end
  
  create_table :article_versions, :force => true do |t|
    t.column :article_id, :integer
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :updated_on, :datetime
    t.column :created_on, :datetime    
    t.column :author_id, :integer
    t.column :revisor_id, :integer  
  end  

  create_table :things, :force => true do |t|
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :project_id, :integer
    t.column :client_id, :integer
  end

  create_table :articles_things, :force => true, :id => false do |t|
    t.column :article_id, :integer
    t.column :thing_id, :integer
  end

  create_table :articles_things_versions, :force => true, :id => false do |t|
    t.column :article_version_id, :integer
    t.column :thing_id, :integer
  end

  create_table :documents, :force => true do |t|
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :updated_on, :datetime
    t.column :created_on, :datetime    
    t.column :author_id, :integer
    t.column :revisor_id, :integer  
    t.column :client_id, :integer
  end
  
  create_table :document_versions, :force => true do |t|
    t.column :document_id, :integer  
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :updated_on, :datetime
    t.column :created_on, :datetime    
    t.column :author_id, :integer
    t.column :revisor_id, :integer  
    t.column :client_id, :integer    
    t.column :client_version_id, :integer
  end 
  
  create_table :articles_documents, :force => true, :id => false do |t|
    t.column :article_id, :integer
    t.column :document_id, :integer
  end    
    
  create_table :articles_documents_versions, :force => true, :id => false do |t|
    t.column :article_version_id, :integer
    t.column :document_version_id, :integer
  end  
  
  create_table :clients, :force => true do |t|
    t.column :project_id, :integer
    t.column :name, :string, :limit => 100
    t.column :version, :integer    
  end

  create_table :client_versions, :force => true do |t|
    t.column :client_id, :integer    
    t.column :project_id, :integer
    t.column :name, :string, :limit => 100
    t.column :version, :integer    
    t.column :thing_id, :integer
  end

  create_table :client_documents_versions, :force => true, :id => false do |t|
    t.column :client_version_id, :integer
    t.column :document_version_id, :integer
  end

  create_table :projects, :force => true do |t|
    t.column :name, :string, :limit => 100
    t.column :version, :integer    
  end

  create_table :project_versions, :force => true do |t|
    t.column :project_id, :integer    
    t.column :name, :string, :limit => 100
    t.column :version, :integer    
  end
  
  create_table :project_clients_versions, :force => true, :id => false do |t|
    t.column :project_version_id, :integer
    t.column :client_version_id, :integer
  end

  create_table :project_things_versions, :force => true, :id => false do |t|
    t.column :project_version_id, :integer
    t.column :thing_id, :integer
  end

end
