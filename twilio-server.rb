require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'

set :c, 0

###get urls from csv file

csv_fname = "callinfo.csv"
csv = CSV.read( csv_fname, :headers=>true)
urls = csv['call_recording_url']
urls = urls.uniq
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

###sinatra get request handling

get %r{/.*} do
	pass if request.path_info == "/favicon.ico"
	pass if settings.c >= url_count
	"#{urls[settings.c]}"
	Twilio::TwiML::Response.new do |r|
	    r.Say getredirectedurl(urls[settings.c])
	end.text
end

get %r{/.*} do
	pass if request.path_info == "/favicon.ico"
	pass if settings.c < url_count
	"no more files!"
end

after do
	if settings.c < url_count && request.path_info != "/favicon.ico"
		settings.c += 1
		puts "sending file #{settings.c} of #{url_count}"
	else
		puts "no files to send!"
	end
end
