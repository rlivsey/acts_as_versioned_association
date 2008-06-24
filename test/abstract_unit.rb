$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'active_record/fixtures'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite'])

load(File.dirname(__FILE__) + "/schema.rb")

# set up custom sequence on widget_versions for DBs that support sequences
if ENV['DB'] == 'postgresql'
  ActiveRecord::Base.connection.execute "DROP SEQUENCE widgets_seq;" rescue nil
  ActiveRecord::Base.connection.remove_column :widget_versions, :id
  ActiveRecord::Base.connection.execute "CREATE SEQUENCE widgets_seq START 101;"
  ActiveRecord::Base.connection.execute "ALTER TABLE widget_versions ADD COLUMN id INTEGER PRIMARY KEY DEFAULT nextval('widgets_seq');"
end

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def assert_difference(object, method, difference=1, ar_obj=true)
    call_chain = method.respond_to?('[]') ? method : [method]
    call = "object." + call_chain.join(".")
    initial_value = eval(call)
    yield
    call_chain.unshift :reload if ar_obj
    call = "object." + call_chain.join(".")
    assert_equal initial_value + difference, eval(call),
      "#{object.class} object's '#{call_chain.join(".")}' method reports incorrect difference"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  # Checks for a change at version head, ensuring older version
  # remains constant
  def assert_version_change(objects, difference=1, &modification_statement)
    obj = objects.last
    if objects.size == 1
      assert_no_obj_difference obj do
        assert_difference obj, [:versions, :size], difference, &modification_statement
      end
    else
      assert_no_obj_difference obj do
        assert_difference obj, [:versions, :size], difference do
          assert_version_change objects - [obj], difference, &modification_statement
        end
      end
    end
  end

  def assert_no_version_change(objects, &modification_statement)
    assert_version_change objects, 0, &modification_statement
  end

  def assert_no_obj_difference(object)
    initial_obj = object.find_version(object.version)
    initial_obj.freeze
    yield
    assert_equal initial_obj, object.find_version(initial_obj.version), "Version of #{object.class} object at version #{initial_obj.version} modified erroneously"
  end
  
end
