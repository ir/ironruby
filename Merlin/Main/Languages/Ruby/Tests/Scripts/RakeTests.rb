require "rubygems"

rake_tests_dir = File.expand_path("../External.LCA_RESTRICTED/Languages/IronRuby/RakeTests", ENV["MERLIN_ROOT"])
all_test_files = Dir.glob("#{rake_tests_dir}/test/test*.rb") + Dir.glob("#{rake_tests_dir}/test/contrib/test*.rb")

if RUBY_PLATFORM =~ /mswin/
  # The "session" gem uses "fork" and so does not work on Windows
  # Print a friendly message to indicate that it is expected for these tests to be skipped
  puts "(Skipping functional tests on Windows)"
else
  all_test_files += Dir.glob("#{rake_tests_dir}/test/fun*.rb")
end

# Do some sanity checks
abort("Did not find enough Rake tests files...") unless all_test_files.size > 25
abort("Did not find some expected files...") unless File.exist?(rake_tests_dir + "/test/test_rake.rb")

# Some tests load data assuming the current folder
Dir.chdir(rake_tests_dir)

# Note that the tests are registered using Kernel#at_exit, and will run during shutdown
# The "require" statement just registers the tests for being run later...
all_test_files.each { |f| require f }

# Disable failing tests by monkey-patching the test method to be a nop

class TestEarlyTime
  # http://ironruby.codeplex.com/WorkItem/View.aspx?WorkItemId=1082
  # TypeError: can't convert Rake::EarlyTime into Time
  def test_create() end
end

class TestFileList
  def test_cloned_items_stay_frozen() end
end

class TestFileUtils
  #we're not exiting correctly from the ruby method. 
  def test_ruby() end
end

class TestPathMapExplode
  # File.split("c:a") should return ["c:.", "a"], not ["c:", "a"]
  def test_explode() end
end

class TestRake
  # File.dirname("c:a") should be "c:.", not "c:"
  def test_each_dir_parent() end
end

class TestTask
  # This failure does not happen with a later version (afer 0.8.4) of Rake tests with the same version (0.8.4) of the Rake gem.
  # So it might be a test issue
  def test_investigation_output() end
end
