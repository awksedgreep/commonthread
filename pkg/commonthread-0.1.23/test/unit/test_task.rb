require 'rubygems'
require 'commonthread_env'
require 'test/unit'

class TaskTest < Test::Unit::TestCase
  
  def setup
    @log = Log.new(:application => 'CommonThread-Test', :log_level => Logger::DEBUG)
    @logconsumer = LogConsumer.new(@log, File.open('/var/tmp/commonthread-test.log', 'a+'))
    @c = Task.new(:log => @log) do
      sleep 0.1
      @log.debug self.class.to_s + ": Task Complete"
    end
  end
  
  def test_task
    assert_nil @c.q
    assert @c.num_threads == 10
    assert @c.threads.length == 10
    assert_kind_of Thread, @c.threads.first
    assert_kind_of Counter, @c.jobs_processed
    assert_kind_of Integer, @c.jobs_processed.to_i
    sleep 0.15
    assert @c.jobs_processed.to_i == 10
  end
  
  def teardown
    @c.shutdown
    @c = nil
    @log = nil
    @logconsumer = nil
  end
  
end
