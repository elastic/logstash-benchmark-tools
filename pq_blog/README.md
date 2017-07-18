# PQ Blog Bechmarking Tools

- **apache.conf**: The logstash configuration used to perform the bechmark

- **monitor.rb**: Monitoring script used to collect the performance metrics

- Sample Apache access logs data can be found at https://s3.amazonaws.com/data.elasticsearch.org/apache_logs/apache_access_logs.tar.gz

## Usage

First you need to have a Ruby interpreter available to run the `monitor.rb` script. Any Ruby should work, this is a very simple script without any dependencies.

Running `monitor.rb` will simply connect to localhost on port 9600 on the logstash monitoring API and start collecting events metrics and output the events per second throughput to *stdout* one line per second.

For example here's how to run it with this configuration and data.

- Download the [sample apache access logs data](https://s3.amazonaws.com/data.elasticsearch.org/apache_logs/apache_access_logs.tar.gz)

- Unpack the sample data

```sh
$ tar xzf apache_access_logs.tar.gz
```

- Start logstash to process the sample data. Note that the configuration is such that dots are output on every processed event, we will just redirect this output to /dev/null

```sh
$ cat apache_access_logs | bin/logstash -f apache.conf > /dev/null
```

- In a separate shell, start the monitoring script

```sh
$ ruby monitor.rb
```

The output should look like this, where each line is the tuple second,event-per-second

```
1,15871
2,15071
3,14883
4,15418
5,15089
6,15130
7,14870
8,15404
9,14973
10,15104
```
