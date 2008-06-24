# predefined as it didn't like some of the circular references 
# IE if document has_many articles but articles wasn't yet loaded
# But can't move articles before documents because articles also
# references documents!
class Document < ActiveRecord::Base; end
class Thing < ActiveRecord::Base; end
class Article < ActiveRecord::Base; end
class Client < ActiveRecord::Base; end
class Project < ActiveRecord::Base; end

class Document < ActiveRecord::Base

  has_and_belongs_to_many :articles
  belongs_to :author
  belongs_to :client
  
  acts_as_versioned
  acts_as_versioned_association :articles, :both_sides => true
  version_association :client, :both_sides => true, :for_has_one => true 

end

class Article < ActiveRecord::Base

  has_and_belongs_to_many :documents
  has_and_belongs_to_many :things
  belongs_to :author
  
  acts_as_versioned
  version_association :documents, :both_sides => true
  version_association :things

end

class Thing < ActiveRecord::Base

  has_and_belongs_to_many :articles
  belongs_to :project
  belongs_to :client

end

class Client < ActiveRecord::Base
  belongs_to :project  
  has_one :document
  has_one :thing
  
  acts_as_versioned
  version_association :project, :both_sides => true
  version_association :document, :both_sides => true
  version_association :thing
end

class Project < ActiveRecord::Base

  has_many :clients
  has_many :things
  
  acts_as_versioned
  version_association :clients, :both_sides => true
  version_association :things

end

class ThingWithAllOptionsSet < ActiveRecord::Base

  has_and_belongs_to_many :articles
  
  acts_as_versioned
  version_association :articles, 
                      :class_name => 'class_name',
                      :join_table => 'join_table',
                      :foreign_key => 'foreign_key',
                      :association_foreign_key => 'assoc_foreign_key'
  

end

