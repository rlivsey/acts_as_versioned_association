class Author < ActiveRecord::Base
  has_many :pages
  has_many :articles
  has_many :documents  
end