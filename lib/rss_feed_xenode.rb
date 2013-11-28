# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# 
# @version 0.1.0
#
# RSS Feed Xenode fetches a specific RSS Feed as defined by the user. It leverages the "Feedzirra" Ruby Gem to check
# for an updated feed from a specified RSS Feed URL, parse it and passes the parsed RSS Feed to its children. If the 
# child Xenode is specifically a SMS Sender Xenode, the RSS Feed Xenode contains logic to pre-format the RSS Feed 
# content to send a brief description and a shortened URL to the SMS Sender. It uses the "googl" Google URL shortener 
# Ruby Gem to creat the shortened URL for a SMS Sender. 
#
# Config file options:
#   loop_delay:         Expected value: a float. Defines number of seconds the Xenode waits before running process(). 
#   enabled:            Expected value: true/false. Determines if the xenode process is allowed to run.
#   debug:              Expected value: true/false. Enables extra logging messages in the log file.
#   rss_to_sms:         Expected value: true/false. If set to true, the RSS Feed will be formatted to a SMS Message.
#   URL:                Expected value: a string. Defines the URL of the RSS Feed to monitor.
#
# Example Configuration File:
#   enabled: true
#   loop_delay: 60
#   debug: false
#   rss_to_sms: true
#   URL: "https://news.google.ca/news/feeds?pz=1&cf=all&ned=ca&hl=en&topic=tc&output=rss"
#
# Example Input:    The RSS Feed Xenode does not expect nor handle any input.  
#
# Example Output:
#   msg.data: <RSS feed content in XML format>
#   msg.data: "From Your Linkedin Network Upd: "John Smith is now connected to Jane Doe" http://goo.gl/ABC123"
#

require 'feedzirra'
require 'googl'

class RSSFeedXenode
  include XenoCore::XenodeBase
  
  def startup
    mctx = "#{self.class}.#{__method__} - [#{@xenode_id}]"

      if @config
        @url = @config[:URL]
        @send_sms = @config[:rss_to_sms]
        do_debug("RSS URL: #{@url}")
      else
        do_debug("#{mctx} - could not parse config.yml #{@config.inspect}")
      end
      
      if @url.empty?
        do_debug("#{mctx} - missing RSS Feed URL")
      else
        @response = Feedzirra::Feed.fetch_and_parse(@url)
      end
        
    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
  end

  def process()
    mctx = "#{self.class}.#{__method__} - [#{@xenode_id}]"
    
    feed_update = Feedzirra::Feed.fetch_and_parse(@url)
    update_raw = Feedzirra::Feed.fetch_raw(@url)

    if feed_update.entries.first.published != @response.entries.first.published
        msg = XenoCore::Message.new
        msg.from_id = @xenode_id

        if @send_sms
          shortened_url = Googl.shorten(feed_update.entries.first.url)
          msg.data = "From " + feed_update.title[0...25] + ": " + "\"" + feed_update.entries.first.title[0...105].delete("\n") + "\" " + shortened_url.short_url 
          do_debug("Latest RSS Feed: #{msg.data[0...30]}")
        else
          if update_raw.is_a? String
            msg.data = update_raw
            do_debug("Latest RSS Feed: #{msg.data[0...30]}")
          end
        end

        write_to_children(msg)
        @response = feed_update
    end

    rescue Exception => e
      catch_error("#{mctx} - #{e.inspect} #{e.backtrace}")
  end  
end
