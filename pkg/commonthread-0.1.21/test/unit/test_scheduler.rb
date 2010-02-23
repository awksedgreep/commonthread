require 'rubygems'
require 'commonthread_env'
require 'test/unit'

class SchedulerTest < Test::Unit::TestCase
  
  def setup
  end
  
  def test_integer
    assert 5.seconds == 5
    assert 1.second == 1
    assert 5.minutes == 300
    assert 1.minute == 60
    assert 5.hours == (5 * 60 * 60)
    assert 1.hour == (1 * 60 * 60)
    assert 5.days == (5 * 24 * 60 * 60)
    assert 1.day == (1 * 24 * 60 * 60)
    assert 5.days.ago.to_i == (Time.now.to_i - (5 * 24 * 60 * 60))
    assert 5.days.from_now.to_i == (Time.now.to_i + (5 * 24 * 60 * 60))
    assert 5.am.to_i == Time.parse('05:00').to_i
    assert 5.pm.to_i == Time.parse('17:00').to_i
  end
  
  def test_time
    # I'll add a test for this one when I'm smarter
    #assert Time.seconds_since_midnight.to_i == Time.parse????
    assert Time.now.midnight.to_i == Time.parse('00:00').to_i
    assert Time.now.today.to_i == Time.parse('00:00').to_i
    assert Time.now.tomorrow.to_i == (Time.now + 86400).to_i
    assert Time.now.every_day.to_i == (Time.now + 86400).to_i
    # I'll add a test for this one when I'm smarter
    #assert Time.now.my_epoch == who even knows
    #assert Time.now.offset == not real sure
  end
  
  def test_every
    before = Time.now
    every 2.seconds
    after = Time.now
    assert (after.to_i >= before.to_i + 1) or (after.to_i <= before.to_i + 3)
    assert after.to_i.even?
  end
  
  def test_at
    before = Time.now.to_i
    at Time.now + 1.second
    after = Time.now.to_i
    assert (after == before + 1)
  end
  
  def test_day
    assert day == 86400
  end
  
  def test_week
    assert week == 7 * day
  end
  
  def test_now
    assert now.to_i == Time.now.to_i
  end
  
  def teardown
  end
  
end