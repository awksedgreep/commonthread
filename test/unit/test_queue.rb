require 'rubygems'
require 'commonthread_env'
require 'minitest/autorun'

class QueueTest < Minitest::Test
  
  def setup
    @q = Queue.new
  end
  
  def test_queue_size
    # Test empty? method
    assert @q.empty?
    assert_equal @q.status, 'Waiting: 0  Length: 0'
    assert_equal @q.to_s, 'Waiting: 0  Length: 0'
    assert_equal @q.length, 0
    @q << 'String'
    assert_equal @q.status, 'Waiting: 0  Length: 1'
    assert_equal @q.to_s, 'Waiting: 0  Length: 1'
    assert_equal @q.length, 1
    @p = @q.pop
    assert_equal @q.status, 'Waiting: 0  Length: 0'
    assert_equal @q.to_s, 'Waiting: 0  Length: 0'
    assert_equal @q.length, 0
  end
  
  def teardown
    @q = nil
  end
  
end