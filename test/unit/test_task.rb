require 'rubygems'
require 'commonthread_env'
require 'minitest/autorun'

class TaskTest < Minitest::Test
  
  def setup
    @log = Log.new(:application => 'CommonThread-Test', :log_level => Logger::DEBUG)
    @logconsumer = LogConsumer.new(@log, File.open('/var/tmp/commonthread-test.log', 'a+'))
    @c = Task.new(:log => @log) do
      sleep 0.1
      # Block executes and increments counter
      true
    end
  end
  
  def test_task
    assert_nil @c.q
    assert_equal 10, @c.num_threads
    assert_equal 10, @c.threads.length
    assert_kind_of Thread, @c.threads.first
    assert_kind_of Counter, @c.jobs_processed
    assert_kind_of Integer, @c.jobs_processed.to_i
    sleep 0.15
    assert_equal 10, @c.jobs_processed.to_i
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
