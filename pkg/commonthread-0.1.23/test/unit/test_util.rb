require 'rubygems'
require 'commonthread_env'
require 'test/unit'

class UtilTest < Test::Unit::TestCase
  
  def setup
    @counter = Counter.new
  end
  
  def test_string_utils
    assert "    This string  ".trim == "This string"
    assert '00:00'.to_time == Time.parse('00:00')
  end
  
  def test_counter
    assert @counter.tick == 1
    assert @counter.tick == 2
    assert @counter.iterate == 3
    assert @counter.iterate == 4
    assert @counter.reset == 0
    assert @counter.set(10) == 10
  end
  
  def teardown
    @q = nil
  end
  
end