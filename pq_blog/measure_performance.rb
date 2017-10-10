require "net/http"
require "json"
require "thread"

Thread.abort_on_exception = true

queue = Queue.new
POLL_DELAY = 1 # in seconds

poller_thread = Thread.new do
  seq = 0

  loop do
    begin
      response = Net::HTTP.start("localhost", 9600, {:read_timeout => 1, :open_timeout => 1}) {|http| http.get("/_node/stats")}
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      $stderr.puts("http request exception: #{e.inspect}")
    end

    if response.is_a?(Net::HTTPSuccess)
      # ignore json exceptions, just crash
      stats = JSON.parse(response.body)
      out = stats["pipeline"].nil? ? stats["events"]["out"] : stats["pipeline"]["events"]["out"]
      queue << { :seq => seq, :out => out }
    else
      $stderr.puts("http response error #{response.inspect}")
    end

    seq += POLL_DELAY
    sleep(POLL_DELAY)
  end
end
stats_thread = Thread.new do
  last_stat = queue.pop

  loop do
    stat = queue.pop
    rate = (stat[:out] - last_stat[:out]) / (stat[:seq] - last_stat[:seq])
    last_stat = stat
    puts("#{stat[:seq]},#{rate}")
  end
end

stats_thread.join
