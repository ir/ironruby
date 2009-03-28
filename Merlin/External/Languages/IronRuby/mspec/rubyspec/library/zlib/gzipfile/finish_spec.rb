require File.dirname(__FILE__) + '/../../../spec_helper'
require 'stringio'
require 'zlib'

describe 'Zlib::GzipFile#close' do
  it 'finishes the stream and closes the io' do
    io = StringIO.new
    Zlib::GzipWriter.wrap io do |gzio|
      gzio.finish

      gzio.closed?.should == true
      # Jirapong add this
      # associate io should not close

      lambda { gzio.orig_name }.should \
        raise_error(Zlib::GzipFile::Error, 'closed gzip stream')
      lambda { gzio.comment }.should \
        raise_error(Zlib::GzipFile::Error, 'closed gzip stream')
    end

    io.string[10..-1].should == "\003\000\000\000\000\000\000\000\000\000"
  end
end
