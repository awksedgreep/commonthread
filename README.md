# CommonThread

> A JRuby framework for building concurrent data processing and message-oriented middleware applications using the producer-consumer pattern.

**Status:** Modernized for JRuby 10.0+ (Ruby 3.4+) - All tests passing ✅

## Overview

CommonThread provides a batteries-included framework for writing multithreaded data processing applications in JRuby. Think "Rails for data pipelines" - it handles the hard parts of threading, queue management, scheduling, logging, and statistics collection so you can focus on your business logic.

### Why CommonThread?

- **True Parallelism**: Built for JRuby to leverage real OS threads without the GIL
- **Producer-Consumer Pattern**: Clean separation between data generation and processing
- **Thread Pool Management**: Configurable thread pools with dynamic scaling
- **Intelligent Shutdown**: Graceful shutdown of worker threads
- **Built-in Monitoring**: Statistics collection and health reporting
- **Rails-Like API**: Familiar patterns for Ruby developers

### Key Features

- 🚀 **Thread Management** - Configurable thread pools with add/remove capabilities
- 📊 **Statistics** - Built-in tracking of jobs processed, queue depth, and thread status
- 📝 **Thread-Safe Logging** - Queue-based logging with multiple output targets
- ⏰ **Scheduling** - Enhanced time/date DSL (e.g., `every 5.minutes`, `at 9.am`)
- 🎛️ **Controller** - Centralized management of producers, consumers, and queues
- 🔌 **DRb Support** - Distributed Ruby for remote management
- 🧪 **Well Tested** - 22 tests, 241 assertions, 100% passing

## Requirements

- **JRuby 10.0+** (Ruby 3.4+)
- **Java 17+** (tested on Java 25)

## Installation

Add to your `Gemfile`:

```ruby
gem 'commonthread', platforms: :jruby
```

Or install directly:

```bash
gem install commonthread
```

## Quick Start

### Basic Producer-Consumer Example

```ruby
require 'commonthread'

# Create a thread-safe queue
queue = Queue.new

# Create a producer (generates work)
producer = Producer.new(num_threads: 5, q: queue) do
  every 1.second
  @q << "Job at #{Time.now}"
end

# Create a consumer (processes work)
consumer = Consumer.new(num_threads: 10, q: queue) do
  job = @q.deq
  puts "Processing: #{job}"
end

# Let it run...
sleep 10

# Graceful shutdown
producer.shutdown
consumer.shutdown
```

### Using the Controller

```ruby
require 'commonthread'

# Controller manages all your components
controller = Controller.new

# Add queues
controller.create_q(:jobs)

# Add producers
controller.create_producer(:data_fetcher, 
  num_threads: 3, 
  q: controller.find_q_by_name(:jobs)) do
  every 30.seconds
  # Fetch data from API, database, etc.
  @q << fetch_data()
end

# Add consumers
controller.create_consumer(:processor,
  num_threads: 10,
  q: controller.find_q_by_name(:jobs)) do
  job = @q.deq
  process(job)
end

# Check status
puts controller.status
# => { queues: {...}, producers: {...}, consumers: {...} }

# Get statistics
puts controller.stats
# => { producers: {data_fetcher: 1523}, consumers: {processor: 1523} }

# Graceful shutdown all components
controller.shutdown
```

## Core Concepts

### Producers

Producers generate work and put it into queues. They run in thread pools and execute an event loop.

```ruby
# Inherit and override event_loop
class DataFetcher < Producer
  def event_loop
    every 5.minutes
    records = fetch_from_database
    records.each { |r| @q << r }
  end
end

# Or use a block
producer = Producer.new(num_threads: 5, q: my_queue) do
  every 10.seconds
  @q << fetch_latest_data()
end
```

### Consumers

Consumers pull work from queues and process it. Also run in thread pools.

```ruby
# Inherit and override event_loop
class RecordProcessor < Consumer
  def event_loop
    record = @q.deq
    process_record(record)
    save_to_database(record)
  end
end

# Or use a block
consumer = Consumer.new(num_threads: 20, q: my_queue) do
  record = @q.deq
  send_to_api(record)
end
```

### Tasks

Tasks are like producers but for scheduled background jobs that don't fit the producer-consumer model.

```ruby
# Health check task
task = Task.new(num_threads: 1) do
  every 1.hour
  check_system_health()
  send_metrics_to_monitoring()
end
```

### Queues

Thread-safe queues (Ruby's `Queue` and `SizedQueue`) with status reporting.

```ruby
q = Queue.new
q << "item"
q.status  # => "Waiting: 0  Length: 1"

sq = SizedQueue.new(100)  # Max size 100
sq.status  # => "Size: 100  Waiting: 0  Length: 0"
```

### Scheduling DSL

Intuitive time expressions for your event loops:

```ruby
every 5.seconds
every 30.minutes
every 1.hour
every 1.day

at 9.am
at 5.pm
at Time.parse('2026-01-20 14:30')

# Time calculations
5.days.ago
3.hours.from_now
Time.now.midnight
Time.now.tomorrow
```

## Thread Management

```ruby
# Create with initial thread pool
producer = Producer.new(num_threads: 10, q: queue)

# Add more threads dynamically
producer.add(5)  # Now 15 threads

# Remove threads
producer.remove(3)  # Now 12 threads

# Check status
producer.status  # => ["run", "sleep", "run", ...]
producer.stats   # => 12458 (jobs processed)

# Shutdown gracefully (waits for current jobs)
producer.shutdown

# Force kill (immediate termination)
producer.kill
```

## Logging

Thread-safe logging with queue-based collection:

```ruby
# Create logger
log = Log.new(
  application: 'MyApp',
  log_level: Logger::INFO
)

# Create log consumer (writes to output)
logconsumer = LogConsumer.new(log, STDOUT)
# or file: LogConsumer.new(log, File.open('app.log', 'a'))

# Use in your code
producer = Producer.new(log: log, ...) do
  @log.info "Processing batch #{batch_id}"
  @log.error "Failed to process: #{error}"
end
```

## Statistics & Monitoring

```ruby
# Individual component stats
producer.stats          # Jobs processed
producer.status         # Thread states
consumer.jobs_processed # Counter object

# Controller-wide monitoring
controller.status
# => {
#   queues: { jobs: "Waiting: 0  Length: 42" },
#   producers: { fetcher: ["run", "sleep", "run"] },
#   consumers: { processor: ["run", "run", ...] }
# }

controller.stats
# => {
#   producers: { fetcher: 15234 },
#   consumers: { processor: 15234 }
# }
```

## Testing

Run the test suite:

```bash
bundle exec rake test
```

All 22 tests passing with 241 assertions on JRuby 10.0.2.0.

## Architecture Notes

- **JRuby Native**: Designed specifically for JRuby's true threading model
- **No GIL**: Take full advantage of multiple CPU cores
- **Thread Pools**: Efficient worker thread management
- **Queue-Based**: Decoupled producer-consumer architecture
- **DRb Ready**: Supports distributed management via Distributed Ruby

## Examples

See the `examples/` directory for complete working examples including:
- Polling systems
- Data pipeline processors
- Scheduled task managers

## History

CommonThread was created in ~2008 during the Ruby 1.8/1.9 era when true threading was challenging in MRI Ruby. It was designed for JRuby to leverage the JVM's native threading capabilities for data processing and middleware applications.

Recently modernized (January 2026) to run on JRuby 10.0+ with Ruby 3.4 compatibility.

## Changelog

### 0.1.56 (2026-01-20) - Modern JRuby Support
- ✅ Updated for JRuby 10.0.2.0 (Ruby 3.4.2)
- ✅ Migrated tests from test/unit to minitest
- ✅ Fixed String mutation issues (Ruby 3.x frozen strings)
- ✅ Fixed thread shutdown mechanism with proper wakeup
- ✅ Modernized gemspec with proper metadata
- ✅ All 22 tests passing (241 assertions)

### 0.1.55
- Updated gemspec and build configuration

### 0.1.54
- Added ability to add/remove threads to/from running pools

### 0.1.46
- Replaced ActiveRecord with DataMapper for thread-safe ORM

### Earlier versions
- 0.1.12 - Task thread manager
- 0.1.11 - Tests for library classes
- 0.1.10 - Testing framework
- 0.1.6 - DRb Server support
- 0.1.0 - Initial release

## License

BSD-Source-Code

## Author

Mark Cotner (mark.cotner@gmail.com)

## Links

- GitHub: https://github.com/awksedgreep/commonthread
- RubyGems: https://rubygems.org/gems/commonthread

