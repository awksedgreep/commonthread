require 'rubygems'
require 'commonthread_env'
require 'minitest/autorun'

class ProducerTest < Minitest::Test
  
  def setup
    @log = Log.new(:application => 'CommonThread-Test', :log_level => Logger::DEBUG)
    @logconsumer = LogConsumer.new(@log, File.open('/var/tmp/commonthread-test.log', 'a+'))
    @q = Queue.new
    @p = Producer.new(:log => @log, :q => @q) do
      sleep 0.1
      @q << Time.now
    end
  end
  
  def test_producer
    refute_nil @p.q
    assert_equal @q, @p.q
    assert_equal 10, @p.num_threads
    assert_equal 10, @p.threads.length
    assert_kind_of Thread, @p.threads.first
    assert_kind_of Counter, @p.jobs_processed
    assert_kind_of Integer, @p.jobs_processed.to_i
    sleep 0.15
    assert_equal 10, @p.jobs_processed.to_i
    assert_equal 10, @q.length
  end
  
  def teardown
    @p.shutdown if @p
    sleep 0.2  # Give threads time to finish
    @logconsumer.shutdown if @logconsumer
    @p = nil
    @log = nil
    @logconsumer = nil
  end
  
end