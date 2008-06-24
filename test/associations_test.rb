require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/things')

class AssocationsTest < Test::Unit::TestCase
   
              # main                   # versioned
    fixtures  :articles,               :article_versions,
              :documents,              :document_versions,
              :projects,               :project_versions,
              :clients,                :client_versions,
              :things,
              :articles_documents,     :articles_documents_versions,
              :articles_things,        :articles_things_versions,
                                       :project_clients_versions,
                                       :project_things_versions,
                                       :client_documents_versions
          
    # Model associations, because I keep forgetting!
    # 
    # has_and_belongs_to_many
    # Article v------ habtm ------v Document
    # Article v------ habtm ------- Thing
    #
    # has_many / belongs_to
    # Project v------ hm/bt ------v Client
    # Project v------ hm/bt ------- Thing
    #
    # has_one / belongs_to
    # Client  v------ ho/bt ------v Document
    # Client  v------ ho/bt ------- Thing  

    def test_defaults_for_habtm_both_sides_versioned
   
      # Article v------ habtm ------v Document
         
      assoc = Document.versioned_class.reflect_on_association(:articles)
  
      assert_equal :has_and_belongs_to_many,      assoc.macro  
      assert_equal 'Article::Version',            assoc.options[:class_name]      
      assert_equal 'articles_documents_versions', assoc.options[:join_table]      
      assert_equal 'document_version_id',         assoc.options[:foreign_key]      
      assert_equal 'article_version_id',          assoc.options[:association_foreign_key]          
  
      assoc = Article.versioned_class.reflect_on_association(:documents)
      
      assert_equal :has_and_belongs_to_many,      assoc.macro    
      assert_equal 'Document::Version',           assoc.options[:class_name]      
      assert_equal 'articles_documents_versions', assoc.options[:join_table]      
      assert_equal 'article_version_id',          assoc.options[:foreign_key]      
      assert_equal 'document_version_id',         assoc.options[:association_foreign_key]          
      
    end
   
    def test_defaults_for_habtm_one_side_versioned
     
      # Article v------ habtm ------- Thing    
      
      assoc = Article.versioned_class.reflect_on_association(:things)
      
      assert_equal :has_and_belongs_to_many,    assoc.macro    
      assert_equal 'Thing',                     assoc.options[:class_name]      
      assert_equal 'articles_things_versions',  assoc.options[:join_table]      
      assert_equal 'article_version_id',        assoc.options[:foreign_key]      
      assert_equal 'thing_id',                  assoc.options[:association_foreign_key]              
    
    end
   
    def test_defaults_for_has_many_both_sides_versioned
   
      # Project v------  hm   ------v Client    
      
      assoc = Project.versioned_class.reflect_on_association(:clients)
      
      assert_equal :has_and_belongs_to_many,    assoc.macro    
      assert_equal 'Client::Version',           assoc.options[:class_name]      
      assert_equal 'project_clients_versions',  assoc.options[:join_table]      
      assert_equal 'project_version_id',        assoc.options[:foreign_key]      
      assert_equal 'client_version_id',         assoc.options[:association_foreign_key]                  
      
      assoc = Client.versioned_class.reflect_on_association(:project)
      
      assert_equal :has_and_belongs_to_many,    assoc.macro    
      assert_equal 'Project::Version',          assoc.options[:class_name]      
      assert_equal 'project_clients_versions',  assoc.options[:join_table]      
      assert_equal 'client_version_id',         assoc.options[:foreign_key]      
      assert_equal 'project_version_id',        assoc.options[:association_foreign_key]                      
    
    end
   
    def test_defaults_for_has_many_one_side_versioned
   
      # Project v------  hm   ------- Thing   
      
      assoc = Project.versioned_class.reflect_on_association(:things)
      
      assert_equal :has_and_belongs_to_many,   assoc.macro    
      assert_equal 'Thing',                    assoc.options[:class_name]      
      assert_equal 'project_things_versions',  assoc.options[:join_table]      
      assert_equal 'project_version_id',       assoc.options[:foreign_key]      
      assert_equal 'thing_id',                 assoc.options[:association_foreign_key]                      
    
    end
   
    def test_defaults_for_has_one_both_sides_versioned
   
      # Client  v------ ho/bt ------v Document
  
      assoc = Client.versioned_class.reflect_on_association(:document)
      
      assert_equal :has_one,                   assoc.macro
      assert_equal 'Document::Version',        assoc.options[:class_name]      
      assert_equal nil,                        assoc.options[:join_table]      
      assert_equal 'client_version_id',        assoc.options[:foreign_key]      
      assert_equal nil,                        assoc.options[:association_foreign_key]                          
      
      assoc = Document.versioned_class.reflect_on_association(:client)
  
      assert_equal :belongs_to,                assoc.macro  
      assert_equal 'Client::Version',          assoc.options[:class_name]      
      assert_equal nil,                        assoc.options[:join_table]      
      assert_equal 'client_version_id',        assoc.options[:foreign_key]      
      assert_equal nil,                        assoc.options[:association_foreign_key]                            
      
    end

    def test_defaults_for_has_one_one_side_versioned
     
      # Client  v------ ho/bt ------- Thing    
      
      assoc = Client.versioned_class.reflect_on_association(:thing)
  
      assert_equal :belongs_to,                assoc.macro  
      assert_equal 'Thing',                    assoc.options[:class_name]      
      assert_equal nil,                        assoc.options[:join_table]      
      assert_equal 'thing_id',                 assoc.options[:foreign_key]      
      assert_equal nil,                        assoc.options[:association_foreign_key]                              
    
    end
   
    def test_sending_options
      
      assoc = ThingWithAllOptionsSet.versioned_class.reflect_on_association(:articles)
  
      assert_equal 'class_name', assoc.options[:class_name]      
      assert_equal 'join_table', assoc.options[:join_table]      
      assert_equal 'foreign_key', assoc.options[:foreign_key]      
      assert_equal 'assoc_foreign_key', assoc.options[:association_foreign_key]      
      
    end
  
    ##### HABTM - BOTH SIDES VERSIONED #####
    # Article v------ habtm ------v Document    
   
    def test_habtm_both_sides_saves_associations_with_new_version
    
      welcome_article = articles(:welcome)
      assert_equal 1, welcome_article.version
       
      readme_doc = documents(:readme)
      assert_equal [readme_doc], welcome_article.documents
      
      welcome_article.title = "changed"
      assert_version_change [welcome_article] do
        assert welcome_article.save
      end
    
      readme_doc_v2 = readme_doc.find_version(2)
      welcome_article_v1 = welcome_article.find_version(1)  
      welcome_article_v2 = welcome_article.find_version(2)
      
      assert_equal [readme_doc], welcome_article.documents
      assert_equal [readme_doc_v2], welcome_article_v1.documents      
     assert_equal [readme_doc_v2], welcome_article_v2.documents            
      
    end
    
    def test_habtm_both_sides_adding_to_assoc_changes_version
    
      welcome_article = articles(:welcome)
      assert_equal 1, welcome_article.version    
    
      readme_doc = documents(:readme)
      assert_equal [readme_doc], welcome_article.documents
      
      another_doc = documents(:another_doc)
      
      assert_version_change [welcome_article] do
        assert welcome_article.documents << another_doc
        assert welcome_article.save
      end
      
      readme_doc_v2 = readme_doc.find_version(2)
      another_doc_v1 = another_doc.find_version(1)      
      welcome_article_v1 = welcome_article.find_version(1)  
      welcome_article_v2 = welcome_article.find_version(2)      
        
      assert_equal [readme_doc, another_doc], welcome_article.documents
      assert_equal [readme_doc_v2], welcome_article_v1.documents      
      assert_equal [readme_doc_v2, another_doc_v1], welcome_article_v2.documents            
    
    end
    
    def test_habtm_both_sides_clearing_assoc_changes_version
    
      welcome_article = articles(:welcome)
      assert_equal 1, welcome_article.version    
    
      readme_doc = documents(:readme)
      assert_equal [readme_doc], welcome_article.documents
            
      assert_version_change [welcome_article] do
        assert welcome_article.documents.clear
        assert welcome_article.save
      end
      
      readme_doc_v2 = readme_doc.find_version(2)      
      welcome_article_v1 = welcome_article.find_version(1)  
      welcome_article_v2 = welcome_article.find_version(2)      
        
      assert_equal [], welcome_article.documents
      assert_equal [readme_doc_v2], welcome_article_v1.documents      
      assert_equal [], welcome_article_v2.documents            
    
    end    
    
    def test_habtm_both_sides_adding_assoc_on_create
    
      new_article = Article.new(:title => "a new article", :body => "the body")
      readme_doc = documents(:readme)
      
      assert new_article.documents << readme_doc
      assert new_article.save
      assert_equal 1, new_article.version
      
      readme_doc_v2 = readme_doc.find_version(2)            
      new_article_v1 = new_article.find_version(1)
      assert_equal [readme_doc], new_article.documents
      assert_equal [readme_doc_v2], new_article_v1.documents
    
    end
    
    ##### HABTM - ONE SIDE VERSIONED #####
    # Article v------ habtm ------- Thing
    
    def test_habtm_one_side_saves_associations_with_new_version
    
      welcome_article = articles(:welcome)
      assert_equal 1, welcome_article.version
    
      thingy = things(:thingy)
      assert_equal [thingy], welcome_article.things
      
      welcome_article.title = "changed"
      assert_version_change [welcome_article] do
        assert welcome_article.save
      end
    
      welcome_article_v1 = welcome_article.find_version(1)  
      welcome_article_v2 = welcome_article.find_version(2)
      
      assert_equal [thingy], welcome_article.things
      assert_equal [thingy], welcome_article_v1.things      
      assert_equal [thingy], welcome_article_v2.things            
      
    end    
    
    def test_habtm_one_side_adding_to_assoc_changes_version
    
      welcome_article = articles(:welcome)
      assert_equal 1, welcome_article.version    
    
      thingy = things(:thingy)
      assert_equal [thingy], welcome_article.things
      
      another_thingy = things(:other_thingy)
      
      assert_version_change [welcome_article] do
        assert welcome_article.things << another_thingy
        assert welcome_article.save
      end
      
      welcome_article_v1 = welcome_article.find_version(1)  
      welcome_article_v2 = welcome_article.find_version(2)      
        
      assert_equal [thingy, another_thingy], welcome_article.things
      assert_equal [thingy], welcome_article_v1.things      
      assert_equal [thingy, another_thingy], welcome_article_v2.things            
    
    end
    
    def test_habtm_one_side_clearing_assoc_changes_version
    
      welcome_article = articles(:welcome)
      assert_equal 1, welcome_article.version    
    
      thingy = things(:thingy)
      assert_equal [thingy], welcome_article.things
            
      assert_version_change [welcome_article] do
        assert welcome_article.things.clear
        assert welcome_article.save
      end
      
      welcome_article_v1 = welcome_article.find_version(1)  
      welcome_article_v2 = welcome_article.find_version(2)      
        
      assert_equal [], welcome_article.things
      assert_equal [thingy], welcome_article_v1.things      
      assert_equal [], welcome_article_v2.things            
    
    end    
    
    def test_habtm_one_side_adding_assoc_on_create
    
      new_article = Article.new(:title => "a new article", :body => "the body")
      thingy = things(:thingy)
      
      assert new_article.things << thingy
      assert new_article.save
      assert_equal 1, new_article.version
      
      new_article_v1 = new_article.find_version(1)
      assert_equal [thingy], new_article.things
      assert_equal [thingy], new_article_v1.things      
    
    end    
    
    
    ##### HAS_MANY / BELONGS_TO BOTH SIDES VERSIONED #####
    # Project v------ hm/bt ------v Client
    
    def test_has_many_both_sides_saves_associations_with_new_version
    
      important_project = projects(:important_project)
      assert_equal 1, important_project.version
    
      bill = clients(:bill)
      assert_equal [bill], important_project.clients
      
      important_project.name = "changed"
      assert_version_change [important_project] do
        assert important_project.save
      end
    
      important_project_v1 = important_project.find_version(1)  
      important_project_v2 = important_project.find_version(2)
      bill_v3 = bill.find_version(3)
      
      assert_equal [bill], important_project.clients
      assert_equal [bill_v3], important_project_v1.clients      
      assert_equal [bill_v3], important_project_v2.clients            
      
    end    
    
    def test_has_many_both_sides_adding_to_assoc_changes_version
  
      important_project = projects(:important_project)
      assert_equal 1, important_project.version
    
      bill = clients(:bill)
      bill.document
      bill_v3 = bill.find_version(3)      
      bill.save
      
      assert_equal [bill], important_project.clients
      important_project_v1 = important_project.find_version(1)        
      assert_equal [bill_v3], important_project_v1.clients
      
      bob = clients(:bob)
      bob.save
      
      assert_version_change [important_project] do
        assert important_project.clients << bob
        assert important_project.save
      end
      
      important_project_v1 = important_project.find_version(1)  
      important_project_v2 = important_project.find_version(2)
      bill_v4 = bill.find_version(4)
      bob_v3 = bob.find_version(3)
                
      assert_equal [bill, bob], important_project.clients
      assert_equal [bill_v3], important_project_v1.clients
      assert_equal [bill_v4, bob_v3], important_project_v2.clients
    
    end
    
    def test_has_many_both_sides_clearing_assoc_changes_version
    
      important_project = projects(:important_project)
      assert_equal 1, important_project.version
    
      bill = clients(:bill)
      bill_v3 = bill.find_version(3)      
      
      assert_equal [bill], important_project.clients
      important_project_v1 = important_project.find_version(1)        
      assert_equal [bill_v3], important_project_v1.clients
            
      assert_version_change [important_project] do
        assert important_project.clients.clear
        assert important_project.save
      end
      
      important_project_v1 = important_project.find_version(1)  
      important_project_v2 = important_project.find_version(2)
      bill_v3 = bill.find_version(3)
                
      assert_equal [], important_project.clients
      assert_equal [bill_v3], important_project_v1.clients
      assert_equal [], important_project_v2.clients
    
    end    
   
    def test_has_many_both_sides_adding_assoc_on_create
    
      new_project = Project.new(:name => "a new project")
      bill = clients(:bill)
      
      assert new_project.clients << bill
      assert new_project.save
      assert_equal 1, new_project.version
      
      bill_v4 = bill.find_version(4)      
      
      new_project_v1 = new_project.find_version(1)
      assert_equal [bill], new_project.clients
      assert_equal [bill_v4], new_project_v1.clients      
    
    end       
    
    
    ##### HAS_MANY / BELONGS_TO ONE SIDE VERSIONED #####
    # Project v------ hm/bt ------- Thing

    def test_has_many_one_side_saves_associations_with_new_version
    
      important_project = projects(:important_project)
      assert_equal 1, important_project.version
    
      thingy = things(:thingy)
      assert_equal [thingy], important_project.things
      
      important_project.name = "changed"
      assert_version_change [important_project] do
        assert important_project.save
      end
    
      important_project_v1 = important_project.find_version(1)  
      important_project_v2 = important_project.find_version(2)
      
      assert_equal [thingy], important_project.things
      assert_equal [thingy], important_project_v1.things      
      assert_equal [thingy], important_project_v2.things            
      
    end    
    
    def test_has_many_one_side_adding_to_assoc_changes_version
 
      important_project = projects(:important_project)
      assert_equal 1, important_project.version
    
      thingy = things(:thingy)
      assert_equal [thingy], important_project.things
            
      other_thingy = things(:other_thingy)
      
      assert_version_change [important_project] do
        assert important_project.things << other_thingy
        assert important_project.save
      end
      
      important_project_v1 = important_project.find_version(1)  
      important_project_v2 = important_project.find_version(2)
                
      assert_equal [thingy, other_thingy], important_project.things
      assert_equal [thingy], important_project_v1.things
      assert_equal [thingy, other_thingy], important_project_v2.things
    
    end
    
    def test_has_many_one_side_clearing_assoc_changes_version
    
      important_project = projects(:important_project)
      assert_equal 1, important_project.version
    
      thingy = things(:thingy)
      assert_equal [thingy], important_project.things
                  
      assert_version_change [important_project] do
        assert important_project.things.clear
        assert important_project.save
      end
      
      important_project_v1 = important_project.find_version(1)  
      important_project_v2 = important_project.find_version(2)
                
      assert_equal [], important_project.things
      assert_equal [thingy], important_project_v1.things
      assert_equal [], important_project_v2.things
    
    end    
   
    def test_has_many_one_side_adding_assoc_on_create
    
      new_project = Project.new(:name => "a new project")
      thingy = things(:thingy)
      
      assert new_project.things << thingy
      assert new_project.save
      assert_equal 1, new_project.version
            
      new_project_v1 = new_project.find_version(1)
      assert_equal [thingy], new_project.things
      assert_equal [thingy], new_project_v1.things      
    
    end       
    
    ##### HAS_ONE / BELONGS_TO BOTH SIDES VERSIONED #####
    # Client  v------ ho/bt ------v Document   
    
    def test_has_one_both_sides_saves_associations_with_new_version
    
      bill = clients(:bill)
      assert_equal 3, bill.version
    
      readme_doc = documents(:readme)
      assert_equal readme_doc, bill.document
    
      readme_doc_v2 = readme_doc.find_version(2)         
      bill_v3 = bill.find_version(3)  
                    
      assert_equal readme_doc_v2, bill_v3.document
      
      bill.name = "changed"
      assert_version_change [bill] do
        assert bill.save
      end
    
      assert_equal 4, bill.version
    
      assert readme_doc_v2 = readme_doc.find_version(2)
      assert readme_doc_v3 = readme_doc.find_version(3)
            
      assert bill_v3 = bill.find_version(3)  
      assert bill_v4 = bill.find_version(4)
   
      assert_equal readme_doc, bill.document
      assert_equal readme_doc_v2, bill_v3.document
      assert_equal readme_doc_v3, bill_v4.document
      
    end
    
    def test_has_one_both_sides_adding_to_assoc_changes_version
    
      bob = clients(:bob)
    
      another_doc = documents(:another_doc)
      assert_equal nil, bob.document
          
      assert_version_change [bob] do
        assert bob.document = another_doc
        assert bob.save
      end
    
      assert_equal 2, bob.version
      assert another_doc_v3 = another_doc.find_version(3)      
      assert bob_v1 = bob.find_version(1)
      assert bob_v2 = bob.find_version(2)
      
      assert_equal another_doc, bob.document
      assert_equal nil, bob_v1.document
      assert_equal another_doc_v3, bob_v2.document          
    
    end
    
    def test_has_one_both_sides_clearing_assoc_changes_version
    
      bill = clients(:bill)
      assert_equal 3, bill.version
    
      readme_doc = documents(:readme)
      assert_equal readme_doc, bill.document
    
      readme_doc_v2 = readme_doc.find_version(2)         
      bill_v3 = bill.find_version(3)  
                    
      assert_equal readme_doc_v2, bill_v3.document
      
      assert_version_change [bill] do
        bill.document = nil
        assert bill.save
      end
    
      assert_equal 4, bill.version
    
      assert readme_doc_v2 = readme_doc.find_version(2)
            
      assert bill_v3 = bill.find_version(3)  
      assert bill_v4 = bill.find_version(4)
   
      assert_equal nil, bill.document
      assert_equal readme_doc_v2, bill_v3.document
      assert_equal nil, bill_v4.document   
    
    end    
    
    def test_has_one_both_sides_adding_assoc_on_create
    
      new_person = Client.new(:name=> "a new person")
      readme_doc = documents(:readme)
      
      assert new_person.document = readme_doc
      assert new_person.save
      assert_equal 1, new_person.version
      
      readme_doc_v3 = readme_doc.find_version(3)            
      new_person_v1 = new_person.find_version(1)
      assert_equal readme_doc, new_person.document
      assert_equal readme_doc_v3, new_person_v1.document
    
    end        
    
    ##### HAS_ONE / BELONGS_TO ONE SIDE VERSIONED #####
    # Client  v------ ho/bt ------- Thing         
    
    def test_has_one_one_side_saves_associations_with_new_version
    
      bill = clients(:bill)
      assert_equal 3, bill.version
    
      thingy = things(:thingy)
      assert_equal thingy, bill.thing
                       
      bill.name = "changed"
      assert_version_change [bill] do
        assert bill.save
      end
    
      assert_equal 4, bill.version
                
      assert bill_v3 = bill.find_version(3)
      assert bill_v4 = bill.find_version(4)
   
      assert_equal thingy, bill.thing
      assert_equal thingy, bill_v3.thing
      assert_equal thingy, bill_v4.thing
      
    end
    
    def test_has_one_one_side_adding_to_assoc_changes_version
    
      bob = clients(:bob)
    
      another_doc = documents(:another_doc)
      assert_equal nil, bob.document
          
      assert_version_change [bob] do
        assert bob.document = another_doc
        assert bob.save
      end
    
      assert_equal 2, bob.version
      assert another_doc_v3 = another_doc.find_version(3)      
      assert bob_v1 = bob.find_version(1)
      assert bob_v2 = bob.find_version(2)
      
      assert_equal another_doc, bob.document
      assert_equal nil, bob_v1.document
      assert_equal another_doc_v3, bob_v2.document          
    
    end
    
    def test_has_one_one_side_clearing_assoc_changes_version
    
      bill = clients(:bill)
      assert_equal 3, bill.version
    
      readme_doc = documents(:readme)
      assert_equal readme_doc, bill.document
    
      readme_doc_v2 = readme_doc.find_version(2)         
      bill_v3 = bill.find_version(3)  
                    
      assert_equal readme_doc_v2, bill_v3.document
      
      assert_version_change [bill] do
        bill.document = nil
        assert bill.save
      end
    
      assert_equal 4, bill.version
    
      assert readme_doc_v2 = readme_doc.find_version(2)
            
      assert bill_v3 = bill.find_version(3)  
      assert bill_v4 = bill.find_version(4)
   
      assert_equal nil, bill.document
      assert_equal readme_doc_v2, bill_v3.document
      assert_equal nil, bill_v4.document   
    
    end    
    
    def test_has_one_one_side_adding_assoc_on_create
    
      new_person = Client.new(:name=> "a new person")
      readme_doc = documents(:readme)
      
      assert new_person.document = readme_doc
      assert new_person.save
      assert_equal 1, new_person.version
      
      readme_doc_v3 = readme_doc.find_version(3)            
      new_person_v1 = new_person.find_version(1)
      assert_equal readme_doc, new_person.document
      assert_equal readme_doc_v3, new_person_v1.document
    
    end        
    
end
