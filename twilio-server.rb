require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'

###initialize variables
Calldata = Struct.new(:url, :call_sid, :transcription_text)

set :c, 0
account_sid = 'AC9fa35979fae87eed73594023536ccf27'
auth_token = '6fd2527fc56e049891fe3dd59dffba53'
@client = Twilio::REST::Client.new account_sid, auth_token

# urls = ["https://calltrackdata.com/webreports/audio.jsp?callID=2086781467&authentication=E83484B24EC788F446EABC7F6B4049A0",
# "https://calltrackdata.com/webreports/audio.jsp?callID=44609277&authentication=5D46E05C2DF139E6C4C47F16206287C1",
# "https://calltrackdata.com/webreports/audio.jsp?callID=2086796602&authentication=3B37BCD861F88B4F8D4366E3004370B5"]

call_data = []

url_count = urls.length

###other functions

def makecall()
	@call = @client.account.calls.create(:url => "http://twilio-server-new-env-muim7wftii.elasticbeanstalk.com/get-twiml", :from => "+18189460042", :to => "18189460048", :method => "POST")
end

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

###sinatra get/post/head handling %r{/.*}

###GET
get '/favicon.ico' do
	puts "We have no icons for you, shoo!"
	return "We have no icons for you, shoo!"
end

get '/get-twiml' do
	pass if settings.c >= url_count
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Play>#{getredirectedurl(urls[settings.c]).sub('https', 'http')}</Play></Response>"
end

get '/get-twiml' do
	pass if settings.c < url_count
	puts "No more files to send!"
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Reject /></Response>"
end

get '/test' do
	puts "testing..."
	return "#{call_data[0]}\n#{call_data[1]}\n#{call_data[2]}\nend"
end

get %r{/.*} do
	puts "Bad request: use '/get-twiml'"
	return "Bad request: use '/get-twiml'"
end

# get '/get-transcriptions'

###POST
post '/get-twiml' do
	pass if settings.c >= url_count 
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Play>#{getredirectedurl(urls[settings.c]).sub('https', 'http')}</Play></Response>"
end

post '/get-twiml' do
	pass if settings.c < url_count
	puts "No more files to send!"
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Reject /></Response>"
end

###HEAD
head %r{/.*} do
	puts "Attempted HEAD"
	return "HEAD AWAY FROM HERE"
end

###after /get-twiml
after '/get-twiml' do
	if settings.c < url_count
		settings.c += 1
		puts "Sent url #{settings.c} of #{url_count}"
	end
end
