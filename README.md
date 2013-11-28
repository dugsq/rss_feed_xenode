RSS Feed Xenode
===============

**RSS Feed Xenode** fetches a specific RSS Feed as defined by the user. It leverages the "Feedzirra" RubyGem to check for an updated feed from a specified RSS Feed URL, parse it and passes the parsed RSS Feed to its children. If the child Xenode is specifically a SMS Sender Xenode, the RSS Feed Xenode contains logic to pre-format the RSS Feed content to send a brief description and a shortened URL to the SMS Sender. It uses the "googl" Google URL shortener RubyGem to creat the shortened URL for a SMS Sender. 

###Configuration file options:###
* loop_delay: defines number of seconds the Xenode waits before running Xenode process. Expects a float.  
* enabled: determines if the Xenode process is allowed to run. Expects true/false.
* debug: enables extra debug messages in the log file. Expects true/false.
* rss_to_sms: If set to true, the RSS Feed will be formatted to a SMS Message. Expects true/false.
* URL: defines the URL of the RSS Feed to monitor. Expects a string.

###Example Configuration File:###
* enabled: true
* loop_delay: 60
* debug: false
* rss_to_sms: true
* URL: "https://news.google.ca/news/feeds?pz=1&cf=all&ned=ca&hl=en&topic=tc&output=rss"

###Example Input:###
* The RSS Feed Xenode does not expect nor handle any input.  

###Example Output:###
* msg.data: <RSS feed content in XML format>
* msg.data: "From Your Linkedin Network Upd: "John Smith is now connected to Jane Doe" http://goo.gl/ABC123"
