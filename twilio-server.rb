require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'

set :c, 0

###get urls from csv file
# begin
	csv_fname = "callinfo.csv"
	csv = CSV.read( csv_fname, :headers=>true)
	urls = csv['call_recording_url']
	urls = urls.uniq
	
	# puts "$mark$ csv was read, there are #{url_count} urls in the list. Should be 204"
	# rescue Exception => msg
	# "$mark$ had this error: #{msg}"
	# puts msg
# end

# urls = ["https://calltrackdata.com/webreports/audio.jsp?callID=2086781467&authentication=E83484B24EC788F446EABC7F6B4049A0",
# "https://calltrackdata.com/webreports/audio.jsp?callID=44609277&authentication=5D46E05C2DF139E6C4C47F16206287C1",
# "https://calltrackdata.com/webreports/audio.jsp?callID=2086796602&authentication=3B37BCD861F88B4F8D4366E3004370B5"]

url_count = urls.length

###check url for redirects

def getredirectedurl(url)
	result = Curl::Easy.perform(url) do |curl| 
	  curl.headers["User-Agent"] = "..."
	  curl.verbose = false
	  curl.follow_location = true 
	  curl.use_ssl = 3
  	  curl.ssl_version = 3
	end
	return result.last_effective_url
end

###sinatra get request handling %r{/.*}

get '/' do
	puts "You should not see this"
	return "You should not see this"
end

get '/favicon.ico' do
	puts "We have no icons for you, shoo!"
	return "We have no icons for you, shoo!"
end

get '/get-twiml' do
	pass if settings.c >= url_count 
	
	twil_obj = Twilio::TwiML::Response.new do |r|
		# r.Say 'Hello. The recording will play now.'
	    r.Say getredirectedurl(urls[settings.c]).sub('https', 'http')
	end

	return twil_obj.text

	###format twil_text for html code
	# temp_text = twil_obj.text
	# temp_text.gsub! '&', '&amp'
	# temp_text.gsub! '<', '&lt'
	# temp_text.gsub! '>', '&gt'
	# temp_text.gsub! '"', '&quot'
	# temp_text.gsub! '\'', '&#039'

	# twil_text = "<html>\n<body>\n<pre>\n" + temp_text + "\n</pre>\n</body>\n</html>"
end

get '/get-twiml' do
	pass if settings.c < url_count
	puts "No more files to send!"
	return "No more files!"
end

post '/get-twiml' do
	pass if settings.c >= url_count 
	
	twil_obj = Twilio::TwiML::Response.new do |r|
		# r.Say 'Hello. The recording will play now.'
	    r.Play getredirectedurl(urls[settings.c]).sub('https', 'http')
	end

	return twil_obj.text

	###format twil_text for html code
	# temp_text = twil_obj.text
	# temp_text.gsub! '&', '&amp'
	# temp_text.gsub! '<', '&lt'
	# temp_text.gsub! '>', '&gt'
	# temp_text.gsub! '"', '&quot'
	# temp_text.gsub! '\'', '&#039'

	# twil_text = "<html>\n<body>\n<pre>\n" + temp_text + "\n</pre>\n</body>\n</html>"
end

post '/get-twiml' do
	pass if settings.c < url_count
	puts "No more files to send!"
	return "No more files!"
end

# post %r{/.*} do
# 	puts "Attempted POST"
# 	return "NO POST ON SUNDAYS"
# end

head %r{/.*} do
	puts "Attempted HEAD"
	return "HEAD AWAY FROM HERE"
end

after '/get-twiml' do
	if settings.c < url_count
		settings.c += 1
		puts "Sent url #{settings.c} of #{url_count}"
	end
end
