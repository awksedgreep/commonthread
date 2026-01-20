require 'rubygems'
require 'commonthread_env'
require 'minitest/autorun'

class ConsumerTest < Minitest::Test
  
  def setup
    @log = Log.new(:application => 'CommonThread-Test', :log_level => Logger::DEBUG)
    @logconsumer = LogConsumer.new(@log, File.open('/var/tmp/commonthread-test.log', 'a+'))
    @q = Queue.new
    10.times do
      @q << Time.now
    end
    @c = Consumer.new(:log => @log, :q => @q) do
      sleep 0.1
      @q.shift
    end
  end
  
  def test_consumer
    refute_nil @c.q
    assert_equal @q, @c.q
    assert_equal 10, @c.num_threads
    assert_equal 10, @c.threads.length
    assert_kind_of Thread, @c.threads.first
    assert_kind_of Counter, @c.jobs_processed
    assert_kind_of Integer, @c.jobs_processed.to_i
    sleep 0.15
    assert_equal 10, @c.jobs_processed.to_i
    assert_equal 0, @q.length
    assert @q.empty?
  end
  
  def teardown
    @c.shutdown if @c
    sleep 0.2  # Give threads time to finish
    @logconsumer.shutdown if @logconsumer
    @c = nil
    @log = nil
    @logconsumer = nil
  end
  
end