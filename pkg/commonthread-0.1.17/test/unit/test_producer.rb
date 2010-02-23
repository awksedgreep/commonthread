require 'rubygems'
require 'commonthread_env'
require 'test/unit'

class ProducerTest < Test::Unit::TestCase
  
  def setup
    @log = Log.new(:application => 'CommonThread-Test', :log_level => Logger::DEBUG)
    @logconsumer = LogConsumer.new(@log, File.open('/var/tmp/commonthread-test.log', 'a+'))
    @q = Queue.new
    @p = Producer.new(:log => @log) do
      sleep 0.1
      @q << Time.now
    end
  end
  
  def test_producer
    assert_nil @p.q
    assert @p.num_threads == 10
    assert @p.threads.length == 10
    assert_kind_of Thread, @p.threads.first
    assert_kind_of Counter, @p.jobs_processed
    assert_kind_of Integer, @p.jobs_processed.to_i
    sleep 0.15
    assert @p.jobs_processed.to_i == 10
    assert @q.length == 10
  end
  
  def teardown
    @p.shutdown
    @p = nil
    @log = nil
    @logconsumer = nil
  end
  
end