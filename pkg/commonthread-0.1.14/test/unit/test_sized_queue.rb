require 'rubygems'
require 'commonthread_env'
require 'test/unit'

class SizedQueueTest < Test::Unit::TestCase
  
  def setup
    @q = SizedQueue.new(3)
  end
  
  def test_queue_size
    # Test empty? method
    assert @q.empty?
    # Check output messages
    assert_equal @q.status, 'Size: 3  Waiting: 0  Length: 0'
    assert_equal @q.to_s, 'Size: 3  Waiting: 0  Length: 0'
    assert_equal @q.length, 0
    # Add to queue and check output messages
    @q << 'String'
    assert_equal @q.status, 'Size: 3  Waiting: 0  Length: 1'
    assert_equal @q.to_s, 'Size: 3  Waiting: 0  Length: 1'
    assert_equal @q.length, 1
    # Fill queue and check output messages
    @q << 'String2'
    @q << 'String3'
    assert_equal @q.status, 'Size: 3  Waiting: 0  Length: 3'
    assert_equal @q.to_s, 'Size: 3  Waiting: 0  Length: 3'
    assert_equal @q.length, 3
    # Pop and check output messages
    @p = @q.pop
    assert_equal @q.status, 'Size: 3  Waiting: 0  Length: 2'
    assert_equal @q.to_s, 'Size: 3  Waiting: 0  Length: 2'
    assert_equal @q.length, 2
    # Shift and check output messages
    @p = @q.shift
    assert_equal @q.status, 'Size: 3  Waiting: 0  Length: 1'
    assert_equal @q.to_s, 'Size: 3  Waiting: 0  Length: 1'
    assert_equal @q.length, 1
    # Enq and check output messages
    @q.enq 'String2'
    assert_equal @q.status, 'Size: 3  Waiting: 0  Length: 2'
    assert_equal @q.to_s, 'Size: 3  Waiting: 0  Length: 2'
    assert_equal @q.length, 2
    assert @q.max == 3
  end
  
  def teardown
    @q = nil
  end
  
end