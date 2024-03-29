## CommonThread Framework

## Summary

CommonThread is a framework for building data processing and message oriented middleware applications.  It strives to be the Rails for data processing.  It takes the burden of statistics collection and management, logging, thread management, queue management, event loop processing, scheduling, and API creation to make application architecture and design much simpler.  The goal is to provide enterprise integration patterns and endpoints for all your data and message processing needs.

Features:
* Data modeling and ORM uses DataMapper(thread-safe) for database access, but you are not limited to that
* Scheduling is an enhanced superset of ActiveSupport with lots of added functionality
* Statistics collection is built in and will track the number of items processed via producers and consumers, will give you live queue status, and overall health of the engine
* Thread management is built in, with easily definable number of threads for producers and consumers working a given queue, the ability to manage the application with thread addition, removal, intelligent shutdown, and kill capabilities
* Event loop specification via overloading and inheritance (sounds much more complex than it is, just specify what you would like the producer/consumer to do in a method definition)
* Built in thread safe logging with various error reporting levels from debug up through fatal
* Initial API creation will be DRb, others may be added soon
* JRuby aware and strongly preferred to avoid GIL
* Future releases could be deployable via WAR file to standard containers

## Installation

```bash
gem install commonthread
```

## Framework creation

```bash
commonthread [application]
```

## Examples

Examples can be found in example directory of gem installation. 

## Notable Changes

* 0.1.54 Added ability to add/remove threads to/from running pools
* 0.1.46 Replaced ActiveRecord with DataMapper for a thread-safe ORM
* 0.1.12 Task thread manager for background thread tasks that don't fit the producer/consumer model
* 0.1.11 Tests for library classes completed
* 0.1.10 Added testing framework
* 0.1.9 Modified statistics collection for more intelligent responses
* 0.1.8 Fixed reporting error in Controller.stats and Controller.status
* 0.1.7 Queue undumped
* 0.1.6 Add DRb Server
* 0.1.5 Remove mysql gem dependency from logging
* 0.1.0 Initial Release

