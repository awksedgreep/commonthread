# CommonThread vs Elixir/BEAM: A Concurrency Comparison

This document compares CommonThread's threading patterns (circa 2008 JRuby) with modern Elixir/BEAM concurrency concepts, highlighting the evolution of concurrent programming paradigms.

## Core Philosophies

### CommonThread (JRuby)
- **Shared Memory**: Multiple OS threads accessing shared queues
- **Pass by Reference**: Objects in queues are shared references (not copied!)
- **Locks & Synchronization**: Thread-safe data structures (Queue, Monitor)
- **Heavy Threads**: Each thread is an OS thread (expensive to create)
- **Mutable State**: Objects can be mutated by any thread holding a reference

### Elixir/BEAM
- **Isolated Processes**: No shared memory between processes
- **Message Passing**: Communication via copying messages
- **Lightweight Processes**: Millions of processes possible
- **Immutable State**: Messages are copied; sender and receiver have independent data

## Pattern Comparisons

### 1. Message Passing

**CommonThread:**
```ruby
# Shared Queue acts as message channel
queue = Queue.new

producer = Producer.new(q: queue) do
  @q << {:process, data}  # Producer enqueues message
end

consumer = Consumer.new(q: queue) do
  message = @q.deq        # Consumer dequeues message
  handle(message)
end
```

**Elixir:**
```elixir
# Each process has its own mailbox
defmodule Worker do
  def loop do
    receive do
      {:process, data} ->
        handle(data)
        loop()
    end
  end
end

pid = spawn(Worker, :loop, [])
send(pid, {:process, data})  # Send to process mailbox
```

**Key Differences**: 
- CommonThread uses an external queue (shared resource) while Elixir processes have built-in mailboxes (isolated)
- **Critical**: In Ruby/JRuby, the object reference is passed - both producer and consumer threads share the same object! If consumer mutates it, producer sees changes.
- In Elixir, messages are copied - sender and receiver have independent data. No shared state possible.

### 2. Worker Processes

**CommonThread:**
```ruby
# Producer = Worker that generates/sends
producer = Producer.new(num_threads: 10, q: queue) do
  every 5.seconds
  data = fetch_from_api()
  @q << data
end

# Consumer = Worker that receives/processes  
consumer = Consumer.new(num_threads: 20, q: queue) do
  item = @q.deq
  process(item)
end
```

**Elixir:**
```elixir
# GenServer = Worker with state and lifecycle
defmodule Producer do
  use GenServer
  
  def handle_info(:fetch, state) do
    data = fetch_from_api()
    Consumer.process(data)
    schedule_next_fetch()
    {:noreply, state}
  end
end

defmodule Consumer do
  use GenServer
  
  def process(data) do
    GenServer.cast(__MODULE__, {:process, data})
  end
  
  def handle_cast({:process, item}, state) do
    # Process item
    {:noreply, state}
  end
end
```

**Parallel**: Both use worker abstractions, but CommonThread workers share a queue while Elixir processes are independent.

### 3. Supervision & Management

**CommonThread:**
```ruby
# Controller manages all components
controller = Controller.new

controller.create_q(:jobs)
controller.create_producer(:fetcher, 
  num_threads: 5, 
  q: controller.find_q_by_name(:jobs))
controller.create_consumer(:processor,
  num_threads: 10,
  q: controller.find_q_by_name(:jobs))

# Manual monitoring
controller.status  # Check all components
controller.stats   # Get statistics

# Graceful shutdown
controller.shutdown
```

**Elixir:**
```elixir
# Supervisor manages child processes
defmodule MyApp.Supervisor do
  use Supervisor
  
  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  
  def init(:ok) do
    children = [
      {Producer, []},
      {ConsumerSupervisor, []}
    ]
    
    # Automatic restart on crash
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

**Key Difference**: CommonThread Controller is manual management; Elixir Supervisor provides automatic restart on failure.

### 4. Thread Pools vs Process Pools

**CommonThread:**
```ruby
# Thread pool = fixed number of OS threads
consumer = Consumer.new(num_threads: 20, q: queue)

# Dynamic scaling
consumer.add(5)     # Add 5 more threads (now 25)
consumer.remove(3)  # Remove 3 threads (now 22)

# Each thread is heavyweight (OS thread)
```

**Elixir:**
```elixir
# ConsumerSupervisor = dynamic process pool
{:ok, supervisor} = ConsumerSupervisor.start_link(
  Worker,
  [],
  strategy: :one_for_one,
  max_children: 20
)

# Processes are lightweight - can easily have thousands
# Dynamic: spawn on demand, die when done
```

**Parallel**: Both support pools of workers, but BEAM processes are ~1000x lighter than OS threads.

### 5. Scheduled Tasks

**CommonThread:**
```ruby
# Task with scheduling DSL
task = Task.new(num_threads: 1) do
  every 5.minutes
  cleanup_old_data()
end

# Time expressions
at 9.am
every 30.seconds
```

**Elixir:**
```elixir
# GenServer with scheduled messages
defmodule ScheduledTask do
  use GenServer
  
  def init(state) do
    schedule_work()
    {:ok, state}
  end
  
  def handle_info(:work, state) do
    cleanup_old_data()
    schedule_work()
    {:noreply, state}
  end
  
  defp schedule_work do
    Process.send_after(self(), :work, :timer.minutes(5))
  end
end
```

**Parallel**: Both support scheduled execution, but CommonThread has richer time DSL while Elixir uses timer-based scheduling.

### 6. Graceful Shutdown

**CommonThread:**
```ruby
# Set shutdown flag, wake sleeping threads
def shutdown
  @threads.each do |thread|
    thread[:shutdown] = true
    thread.wakeup if thread.status == "sleep"
  end
end

# Thread checks flag and exits
until Thread.current[:shutdown]
  event_loop
end
```

**Elixir:**
```elixir
# Send shutdown message
def terminate(_reason, state) do
  # Cleanup code here
  :ok
end

# Or trap exits
Process.flag(:trap_exit, true)

receive do
  {:EXIT, _pid, _reason} ->
    cleanup()
end
```

**Key Difference**: CommonThread uses flags and wakeup; Elixir uses messages and process links.

### 7. Statistics & Monitoring

**CommonThread:**
```ruby
# Manual counter tracking
@jobs_processed = Counter.new

def event_loop
  process_job()
  @jobs_processed.tick
end

# Manual status checking
producer.stats   # Jobs processed
queue.status     # Queue depth
controller.status # Everything
```

**Elixir:**
```elixir
# Telemetry for metrics
:telemetry.execute([:worker, :job, :complete], %{count: 1})

# Observer for system monitoring
:observer.start()

# Built-in process info
Process.info(pid)
:sys.get_state(pid)
```

**Parallel**: Both track statistics, but BEAM has built-in observability tools.

## Conceptual Mapping

| CommonThread | Elixir/BEAM | Notes |
|--------------|-------------|-------|
| `Queue` | Process Mailbox | External vs built-in |
| `Producer` | GenServer (sender) | Thread pool vs process |
| `Consumer` | GenServer (receiver) | Shared queue vs isolated |
| `Controller` | Supervisor | Manual vs automatic restart |
| `Task` | GenServer (scheduled) | Time DSL vs timers |
| `Thread.new` | `spawn/1` | OS thread vs BEAM process |
| `@q << item` | `send(pid, msg)` | Queue push vs message send |
| `@q.deq` | `receive do...end` | Queue pop vs mailbox receive |
| `Counter` | Agent/ETS | Shared state vs isolated/table |
| `thread[:shutdown]` | Process message/exit | Flag vs message/signal |
The Shared Reference Problem

**CommonThread (Ruby/JRuby):**
```ruby
# Producer creates and enqueues object
data = { id: 1, status: 'pending' }
queue << data

# Consumer dequeues SAME object reference
item = queue.deq
item[:status] = 'processed'  # Mutates the original object!

# If producer still holds reference, it sees the change
# This is why thread safety is HARD in shared memory systems
```

**Elixir (BEAM):**
```elixir
# Sender creates and sends message
data = %{id: 1, status: "pending"}
send(pid, data)

# Receiver gets a COPY of the data
receive do
  item -> 
    item = Map.put(item, :status, "processed")  # Creates new map
    # Sender's data is unchanged - immutability enforced
end
```

**The Big Difference**: In JRuby, you must be careful that objects themselves are thread-safe. The `Queue` is synchronized, but if you put a mutable Hash in it, multiple threads share that Hash reference. In Elixir, this problem doesn't exist - data is always copied.

### Concurrency Costs

**CommonThread (OS Threads):**
- Thread creation: ~1-2 MB memory per thread
- Context switching: Kernel-level, expensive
- Practical limit: ~hundreds to low thousands of threads
- Coordination: Locks, monitors, synchronized queues
- **Data sharing**: References shared (fast but dangerous)

**Elixir (Green Processes):**
- Process creation: ~2 KB memory per process
- Context switching: VM-level, cheap
- Practical limit: millions of processes
- Coordination: Message passing, no shared memory
- **Data sharing**: Messages copied (safer but has cost)
- Context switching: VM-level, cheap
- Practical limit: millions of processes
- Coordination: Message passing, no shared memory

### Error Handling Philosophy

**CommonThread:**
```ruby
# Manual error handling
begin
  event_loop
rescue Exception => e
  @log.error e.message (Queue is safe, but objects in it are not!)
- Manual resource management
- One process, many threads
- **Shared references**: Fast but requires discipline

Elixir/BEAM represents the "message passing" era:
- Isolation by default
- No shared state (impossible to share by design)
- Automatic supervision
- Many processes, no threads
- **Copied data**: Safer but has memory/performance cost

Both solve the same problem (concurrent data processing) but with different trade-offs shaped by their runtime environments (JVM vs BEAM VM).

### The Safety Trade-off

**JRuby/CommonThread**: Fast (shared references) but dangerous (easy to have race conditions on the objects themselves)

**Elixir/BEAM**: Safer (copied data, no race conditions) but potentially slower (copying cost) and uses more memory for large messages

In practice, BEAM optimizations like binary reference counting and large binary sharing mean the copying cost is often negligible, while the safety benefits are huge
  {:reply, result, state}
end
```

### When to Use Each

**CommonThread/JRuby When:**
- Existing JVM infrastructure
- Need Java library integration
- CPU-bound parallel processing
- Legacy Ruby codebases to modernize

**Elixir/BEAM When:**
- High concurrency requirements (thousands+ of connections)
- Distributed systems
- Fault-tolerant systems
- Soft real-time systems
- Modern greenfield projects

## Evolution of Thought

CommonThread (2008) represents the "shared memory + locks" era of concurrency:
- Careful synchronization required
- Thread-safe data structures
- Manual resource management
- One process, many threads

Elixir/BEAM represents the "message passing" era:
- Isolation by default
- No shared state
- Automatic supervision
- Many processes, no threads

However, there's a fundamental difference: **In JRuby/CommonThread, objects in queues are shared references** - multiple threads can mutate the same object. The Queue is thread-safe, but the objects in it are not automatically protected. This is the classic "shared memory" challenge.

**In Elixir, messages are copied** - sender and receiver have independent data. You literally cannot have a race condition on the data itself (though you can still have logical race conditions in your business logic).

The evolution from CommonThread to modern Elixir represents a shift from "shared memory with locks" to "isolated processes with copied messages" - trading some performance (copying cost) for massive safety gains (impossible to mutate shared state). BEAM makes this trade-off viable through VM optimizations, lightweight processes, and smart memory management

Both solve the same problem (concurrent data processing) but with different trade-offs shaped by their runtime environments (JVM vs BEAM VM).

## Interesting Note

CommonThread's `Queue` pattern predates Go's channels (2009) and has similarities to Erlang's message passing (1986), showing how good concurrent patterns transcend specific languages. The producer-consumer pattern is universal; the implementation details vary by platform capabilities.

---

**For the Podcast:** CommonThread shows that Ruby developers were thinking about concurrency patterns similar to BEAM even before Elixir existed. The frameworks use different mechanisms (shared queues vs mailboxes, OS threads vs green processes) but solve similar problems. The evolution from CommonThread to modern Elixir represents a shift from "shared memory with locks" to "isolated processes with messages" - not because one is universally better, but because each fits its runtime model optimally.
