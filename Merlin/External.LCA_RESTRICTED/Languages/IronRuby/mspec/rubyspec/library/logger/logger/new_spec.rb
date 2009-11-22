require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/common'

describe "Logger#new" do

  before :each do
    @file_path = tmp("test_log.log")
    @log_file = File.open(@file_path, "w+")
    @l = nil
  end

  after :each do
    @log_file.close unless @log_file.closed?
    @l.close if @l
    begin
      File.unlink(@file_path) if File.exists?(@file_path)
    rescue Errno::EACCES
      File.unlink(@file_path) if File.exists?(@file_path)
    end
  end

   it "creates a new logger object" do
     @l = Logger.new(STDERR)
     lambda { @l.add(Logger::WARN, "Foo") }.should output_to_fd(/Foo/, STDERR)
   end

   it "receives a logging device as first argument" do
     l = Logger.new(@log_file)
     l.add(Logger::WARN, "Test message")

     @log_file.rewind
     LoggerSpecs::strip_date(@log_file.readline).should == "WARN -- : Test message\n"
   end

  it "receives a frequency rotation as second argument" do
     lambda { Logger.new(@log_file, "daily")}.should_not raise_error
     lambda { Logger.new(@log_file, "weekly")}.should_not raise_error
     lambda { Logger.new(@log_file, "monthly")}.should_not raise_error
  end
  
  it "also receives a number of log files to keep as second argument" do
    lambda { Logger.new(@log_file, 1)}.should_not raise_error
  end

  it "receivs a maximum logfile size as third argument" do
    # This should create 2 small log files, logfile_test and logfile_test.0
    # in /tmp, each one with a different message.
    path = tmp("logfile_test.log")
    path0 = path + ".0"

    l = Logger.new(path, 2, 5)
    l.add Logger::WARN, "foo"
    l.add Logger::WARN, "bar"

    File.exists?(path).should be_true
    File.exists?(path0).should be_true 
    f = File.open(path)
    f0 = File.open(path0)
    # first line will be a comment so we'll have to skip it.
    LoggerSpecs::strip_date(f0.readlines.last).should == "WARN -- : foo\n"
    LoggerSpecs::strip_date(f.readlines.last).should == "WARN -- : bar\n"

    f.close
    f0.close
    l.close

    File.unlink(path)
    File.unlink(path0)
  end
end
