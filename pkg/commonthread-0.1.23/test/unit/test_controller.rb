require 'rubygems'
require 'commonthread_env'
require 'test/unit'
require 'pp'

class ControllerTest < Test::Unit::TestCase
  
  def setup
    @log = Log.new(:application => 'CommonThread-Test', :log_level => Logger::DEBUG)
    @logconsumer = LogConsumer.new(@log, File.open('/var/tmp/commonthread-test.log', 'a+'))
    @c = Controller.new(:log => @log)
    @p1 = Producer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @p2 = Producer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @p3 = Producer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @p4 = Producer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @c1 = Consumer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @c2 = Consumer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @c3 = Consumer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @c4 = Consumer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @s1 = Producer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @s2 = Consumer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @k1 = Producer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
    @k2 = Consumer.new(:num_threads => 1, :log => @log) do
      sleep 0.05
      #puts "not sleeping"
    end
  end
  
  def test_controller_init
    assert_kind_of Log, @c.log
    assert_kind_of Hash, @c.consumers
    assert_kind_of Hash, @c.producers
    assert_kind_of Hash, @c.queues
    assert_not_nil $controllers
    assert_kind_of Array, $controllers
    assert !$controllers.empty?
    assert $controllers.length > 0
  end
  
  def test_controller_status
    assert status = @c.status
    assert_kind_of Hash, status
    assert status.length == 3
    assert status.has_key?(:queues)
    assert_kind_of Hash, status[:queues]
    assert status[:queues].empty?
    assert status.has_key?(:producers)
    assert_kind_of Hash, status[:producers]
    assert status[:producers].empty?
    assert status.has_key?(:consumers)
    assert_kind_of Hash, status[:consumers]
    assert status[:consumers].empty?
  end

  def test_controller_stats
    assert stats = @c.stats
    assert_kind_of Hash, stats
    assert stats.length == 2
    assert stats.has_key?(:producers)
    assert_kind_of Hash, stats[:producers]
    assert stats[:producers].empty?
    assert stats.has_key?(:consumers)
    assert_kind_of Hash, stats[:consumers]
    assert stats[:consumers].empty?
  end
  
  def test_controller_queues
    assert_kind_of Queue, @c.add_q(:this)
    assert qs = @c.queues
    assert_kind_of Hash, qs
    assert qs.length == 1
    assert qs.has_key?(:this)
    assert_kind_of Queue, qs[:this]
    assert_kind_of Queue, @c.create_q(:that)
    assert qs = @c.queues
    assert_kind_of Hash, qs
    assert qs.length == 2
    assert qs.has_key?(:that)
    assert_kind_of Queue, qs[:that]
    assert @c.del_q(:that)
    assert qs.length == 1
    assert !qs.has_key?(:that)
    assert_kind_of Hash, @c.q_status
    assert_kind_of String, @c.q_status[:this]
    assert @c.q_status.has_key?(:this)
    assert_kind_of String, @c.q_status[:this]
    assert @c.q_status[:this] == "Waiting: 0  Length: 0"
  end
  
  def test_controller_producers
    assert_kind_of Producer, @c.add_producer(:mark, @p1)
    assert_kind_of Hash, ps = @c.producers
    assert ps.keys.length == 1
    assert ps.has_key?(:mark)
    status = @c.producer_status
    assert_kind_of Hash, status
    assert status.length == 1
    assert status.has_key?(:mark)
    assert (status[:mark][0] == "sleep" or status[:mark][0] == "run")
    stats = @c.producer_stats
    assert stats[:mark] == 0
    assert stats.length == 1
    assert @c.shutdown_producers
    sleep 0.1
    status = @c.producer_status
    assert status[:mark][0] == "dead"
    assert_kind_of Producer, @c.add_producer(:wesley, @p2)
    assert_kind_of Hash, ps = @c.producers
    assert ps.keys.length == 2
    assert ps.has_key?(:wesley)
    status = @c.producer_status
    assert_kind_of Hash, status
    assert status.length == 2
    assert status.has_key?(:wesley)
    assert (status[:wesley][0] == "sleep" or status[:wesley][0] == "run")
    stats = @c.producer_stats
    assert stats[:wesley] > 0
    assert stats.length == 2
    assert @c.shutdown_producer(:wesley)
    sleep 0.1
    status = @c.producer_status
    assert status[:wesley][0] == "dead"
    assert_kind_of Producer, @c.add_producer(:mingjia, @p3)
    assert_kind_of Hash, ps = @c.producers
    assert ps.keys.length == 3
    assert ps.has_key?(:mingjia)
    status = @c.producer_status
    assert_kind_of Hash, status
    assert status.length == 3
    assert status.has_key?(:mingjia)
    assert (status[:mingjia][0] == "sleep" or status[:mingjia][0] == "run")
    stats = @c.producer_stats
    assert stats[:mingjia] > 0
    assert stats.length == 3
    assert @c.kill_producers
    sleep 0.1
    status = @c.producer_status
    assert status[:mingjia][0] == "dead"
    assert_kind_of Producer, @c.add_producer(:bobby, @p4)
    assert_kind_of Hash, ps = @c.producers
    assert ps.keys.length == 4
    assert ps.has_key?(:bobby)
    status = @c.producer_status
    assert_kind_of Hash, status
    assert status.length == 4
    assert status.has_key?(:bobby)
    assert (status[:bobby][0] == "sleep" or status[:bobby][0] == "run")
    stats = @c.producer_stats
    assert stats[:bobby] > 0
    assert stats.length == 4
    assert @c.kill_producer(:bobby)
    sleep 0.1
    status = @c.producer_status
    assert status[:bobby][0] == "dead"
  end
  
  def test_controller_consumers
    assert_kind_of Consumer, @c.add_consumer(:mark, @c1)
    assert_kind_of Hash, ps = @c.consumers
    assert ps.keys.length == 1
    assert ps.has_key?(:mark)
    status = @c.consumer_status
    assert_kind_of Hash, status
    assert status.length == 1
    assert status.has_key?(:mark)
    assert (status[:mark][0] == "sleep" or status[:mark][0] == "run")
    stats = @c.consumer_stats
    assert stats[:mark] == 0
    assert stats.length == 1
    assert @c.shutdown_consumers
    sleep 0.1
    status = @c.consumer_status
    assert status[:mark][0] == "dead"
    assert_kind_of Consumer, @c.add_consumer(:wesley, @c2)
    assert_kind_of Hash, ps = @c.consumers
    assert ps.keys.length == 2
    assert ps.has_key?(:wesley)
    status = @c.consumer_status
    assert_kind_of Hash, status
    assert status.length == 2
    assert status.has_key?(:wesley)
    assert (status[:wesley][0] == "sleep" or status[:wesley][0] == "run")
    stats = @c.consumer_stats
    assert stats[:wesley] > 0
    assert stats.length == 2
    assert @c.shutdown_consumer(:wesley)
    sleep 0.1
    status = @c.consumer_status
    assert status[:wesley][0] == "dead"
    assert_kind_of Consumer, @c.add_consumer(:mingjia, @c3)
    assert_kind_of Hash, ps = @c.consumers
    assert ps.keys.length == 3
    assert ps.has_key?(:mingjia)
    status = @c.consumer_status
    assert_kind_of Hash, status
    assert status.length == 3
    assert status.has_key?(:mingjia)
    assert (status[:mingjia][0] == "sleep" or status[:mingjia][0] == "run")
    stats = @c.consumer_stats
    assert stats[:mingjia] > 0
    assert stats.length == 3
    assert @c.kill_consumers
    sleep 0.1
    status = @c.consumer_status
    assert status[:mingjia][0] == "dead"
    assert_kind_of Consumer, @c.add_consumer(:bobby, @c4)
    assert_kind_of Hash, ps = @c.consumers
    assert ps.keys.length == 4
    assert ps.has_key?(:bobby)
    status = @c.consumer_status
    assert_kind_of Hash, status
    assert status.length == 4
    assert status.has_key?(:bobby)
    assert (status[:bobby][0] == "sleep" or status[:bobby][0] == "run")
    stats = @c.consumer_stats
    assert stats[:bobby] > 0
    assert stats.length == 4
    assert @c.kill_consumer(:bobby)
    sleep 0.1
    status = @c.consumer_status
    assert status[:bobby][0] == "dead"
  end
  
  def test_controller_shutdown
    @c.add_producer(:jeanette, @s1)
    @c.add_consumer(:teresa, @s2)
    assert @c.shutdown
    sleep 0.1
    assert @c.producers[:jeanette].status[0] == "dead"
    assert @c.consumers[:teresa].status[0] == "dead"
  end
  
  def test_controller_kill
    @c.add_producer(:cindy, @k1)
    @c.add_consumer(:adam, @k2)
    assert @c.kill
    sleep 0.1
    assert @c.producers[:cindy].status[0] == "dead"
    assert @c.consumers[:adam].status[0] == "dead"
  end
  
  def teardown
    @c.shutdown
    @p1 = nil
    @p2 = nil
    @p3 = nil
    @p4 = nil
    @c1 = nil
    @c2 = nil
    @c3 = nil
    @c4 = nil
    @c = nil
  end
  
end
