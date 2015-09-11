require 'benchmark'
require 'rest-client'
require 'work_queue'
require 'celluloid/current'

class UrlChecker1
  def hi url
  	RestClient.get url
  end
end

class UrlChecker2 < UrlChecker1
  include Celluloid
end

n = 200
pool_size = 5
url = 'http://localhost:4567/hi'
wq = WorkQueue.new pool_size
checker1 = UrlChecker1.new
checker2 = UrlChecker2.pool(size: pool_size)

Benchmark.bm(10) do |x|
  x.report('one thread:') do
  	n.times do
  		checker1.hi url
  	end
  end

  x.report('work_queue:') do
  	n.times do
  		wq.enqueue_b do
  		  checker1.hi url
  		end
  	end
  	wq.join
  end

  x.report('celluloid:') do
  	n.times do
  		checker2.async.hi url
  	end
  end
end
