require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'

set :c, 0

###get urls from csv file
# begin
# 	csv_fname = "callinfo.csv"
# 	csv = CSV.read( csv_fname, :headers=>true)
# 	urls = csv['call_recording_url']
# 	urls = urls.uniq
# 	
# 	puts "$mark$ csv was read, there are #{url_count} urls in the list. Should be 204"
# 	rescue Exception => msg
# 	"$mark$ had this error: #{msg}"
# 	puts msg
# end

urls = ["https://calltrackdata.com/webreports/audio.jsp?callID=2086781467&authentication=E83484B24EC788F446EABC7F6B4049A0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086701093&authentication=75E0E52C2F022233FC3070FC979C7E33",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086725818&authentication=21C006EED2356B4A1D796F0DE957C6DA",
"https://calltrackdata.com/webreports/audio.jsp?callID=44609277&authentication=5D46E05C2DF139E6C4C47F16206287C1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086796602&authentication=3B37BCD861F88B4F8D4366E3004370B5"]

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
	pass if request.path_info == "/favicon.ico" || settings.c >= url_count 
	
	twil_obj = Twilio::TwiML::Response.new do |r|
		# r.Say 'Hello. The recording will play now.'
	    r.Say getredirectedurl(urls[settings.c]).sub('https', 'http')
	end

	settings.c += 1
	puts "sending file #{settings.c} of #{url_count}"
	twil_text = twil_obj.text

	###format twil_text for html code
	# temp_text = twil_obj.text
	# temp_text.gsub! '&', '&amp'
	# temp_text.gsub! '<', '&lt'
	# temp_text.gsub! '>', '&gt'
	# temp_text.gsub! '"', '&quot'
	# temp_text.gsub! '\'', '&#039'

	# twil_text = "<html>\n<body>\n<pre>\n" + temp_text + "\n</pre>\n</body>\n</html>"
end

get '/' do
	pass if request.path_info == "/favicon.ico" || settings.c < url_count
	
	puts "no more files to send!"
	"no more files to send!"
end

post '/' do
	status 200
	puts "why is it posting?"
end

head '/' do
	status 200
	puts "it is requesting the headers."
end

# after '/' do
# 	if settings.c < url_count && request.path_info != "/favicon.ico"
# 		# settings.c += 1
# 		puts "sending file #{settings.c} of #{url_count}"
# 	else
# 		puts "no files to send!"
# 	end
# end
