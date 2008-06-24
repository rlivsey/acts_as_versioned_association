# Copyright (c) 2006 Richard Livsey
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ActiveRecord #:nodoc:
  module Acts #:nodoc:

    module VersionedAssociation

      def self.included(base) # :nodoc:
        base.extend ClassMethods    
      end

      module ClassMethods
         
        #      
        # == Configuration options
        #
        # * <tt>class_name</tt> - versioned model class name (default: Model::Version)
        # * <tt>join_table</tt> - versioned associations table name (default: depends on join type)
        # * <tt>foreign_key</tt>
        # * <tt>association_foreign_key</tt>
        # * <tt>both_sides</tt> - whether or not both sides of the association are versioned (default: false)
        # * <tt>for_has_one</tt> - indicates a belongs_to is for a has_one relationship (default: false - IE assumes it's for a has_many)
        #
        
        def acts_as_versioned_association(association_name, options = {})

          # allow multiple calls, but do this only on the first call
          unless self.included_modules.include?(ActiveRecord::Acts::VersionedAssociation::ActMethods)
            send :include, ActiveRecord::Acts::VersionedAssociation::ActMethods
            cattr_accessor :versioned_associations
            self.versioned_associations = []
          end
          
          # must have called acts_as_versioned first
          return unless self.included_modules.include?(ActiveRecord::Acts::Versioned::ActMethods)
          
          # only allow this to be called once per association
          return if self.versioned_associations.include? association_name
          
          # store the options with the association name
          self.versioned_associations << {association_name => options}
          
          association = self.reflect_on_association(association_name)
                                            
          if options[:both_sides]
            assoc_version_class = "#{association.klass.to_s}::Version"
            assoc_f_key = "#{association.klass.to_s.underscore.singularize}_version_id"
          else
            assoc_version_class = association.klass.to_s            
            assoc_f_key = association.klass.to_s.foreign_key
          end       
          
          f_key = "#{self.to_s.underscore.singularize}_version_id"                                    
                                
          assoc_join = case association.macro
            when :has_and_belongs_to_many;  "#{association.options[:join_table]}_versions"
            when :has_many;                 "#{self.to_s.underscore.singularize}_#{association_name}_versions"
            when :has_one;                  "#{self.to_s.underscore.singularize}_#{association_name.to_s.pluralize}_versions"
            when :belongs_to;               "#{association_name}_#{self.to_s.underscore.pluralize}_versions"
          end
          
          if association.macro == :has_one
            if options[:both_sides]
              versioned_class.has_one association_name, 
                                                    :class_name =>              options[:class_name]              || assoc_version_class, 
                                                    :foreign_key =>             options[:foreign_key]             || f_key          
            else
              versioned_class.belongs_to association_name, 
                                                    :class_name =>              options[:class_name]              || assoc_version_class, 
                                                    :foreign_key =>             options[:foreign_key]             || assoc_f_key          
            end

          # if it's a belongs_to for a has_one...
          elsif association.macro == :belongs_to && options[:for_has_one]

            versioned_class.belongs_to association_name, 
                                                    :class_name =>              options[:class_name]              || assoc_version_class, 
                                                    :foreign_key =>             options[:foreign_key]             || assoc_f_key          
            
          else
          
            versioned_class.has_and_belongs_to_many association_name, 
                                                    :class_name =>              options[:class_name]              || assoc_version_class, 
                                                    :join_table =>              options[:join_table]              || assoc_join,
                                                    :foreign_key =>             options[:foreign_key]             || f_key,
                                                    :association_foreign_key => options[:association_foreign_key] || assoc_f_key           
          
          end
                    
        end
        
        # add an alias to this so we can call it by 'version_association' - a bit less typing
        alias_method :version_association, :acts_as_versioned_association            
      end
      
      module ActMethods
        def self.included(base) # :nodoc:
          base.class_eval do 
            alias_method :clone_versioned_model_without_associations, :clone_versioned_model
            alias_method :clone_versioned_model, :clone_versioned_model_with_associations     
            alias_method :save_version_on_create, :new_save_version_on_create
          end
        end

        def current_version
          find_version(self.version)
        end

        def new_save_version_on_create
          rev = self.class.versioned_class.new
          self.clone_versioned_model(self, rev)
          rev.version = send(self.class.version_column)
          rev.send("#{self.class.versioned_foreign_key}=", self.id)
          rev.save
          self.clone_associations_after_version_saved(self, rev)
        end

        def clone_associations_after_version_saved(orig_model, new_model)
          
          self.versioned_associations.each do |association_with_options|
            association_name = association_with_options.keys[0]
            association_options = association_with_options[association_name]
            association = self.class.reflect_on_association(association_name) 
                        
            if association.macro == :has_one && association_options[:both_sides]      
              if associated_item = self.send(association_name)   
                rev = associated_item.class.versioned_class.new
                associated_item.clone_versioned_model(associated_item, rev)
                rev.version = associated_item.next_version
                rev.send("#{associated_item.class.versioned_foreign_key}=", associated_item.id)          
                rev.send("#{self.class.to_s.underscore}=".to_sym, self.find_version(self.version))                  
                rev.save                            
              end      
            end
          end
        end

        def clone_versioned_model_with_associations(orig_model, new_model)
          clone_versioned_model_without_associations(orig_model, new_model)

          self.versioned_associations.each do |association_with_options|
            association_name = association_with_options.keys[0]
            association_options = association_with_options[association_name]
         
            association = self.class.reflect_on_association(association_name) 
          
            if [:has_and_belongs_to_many, :has_many].include? association.macro           
              
              associated_items = self.send(association_name)               
                                        
              if association_options[:both_sides]
                associated_items = associated_items.collect{|i| i.find_version(i.version) }
              end
              
              new_model.send("#{association_name}=".to_sym, associated_items) unless associated_items.empty?
                     
            elsif association.macro == :has_one && !association_options[:both_sides]
                            
              associated_item = self.send(association_name)
              new_model.send("#{association_name}=".to_sym, associated_item) if associated_item        
              
            elsif association.macro == :belongs_to
              # this should be covered by the other sides of the association.
              
#              associated_item = self.send(association_name)                                                           
#              if associated_item && association_options[:both_sides]
#                associated_item = associated_item.find_version(associated_item.version)
#              end
#
#              if associated_item && association_options[:for_has_one]
#                new_model.send("#{association_name}=".to_sym, associated_item) if associated_item     
#              else
#                new_model.send("#{association_name}=".to_sym, [associated_item]) if associated_item     
#              end

            end            
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::VersionedAssociation
