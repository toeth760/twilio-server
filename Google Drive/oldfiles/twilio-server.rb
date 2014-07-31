require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'
#require 'httpclient' => sinatra require does not lke this require for some reason... find out why (need this for redirects)
#require 'uri'
#require 'rubygems'

set :port, 4568
set :c, 0

###get list of urls from csv file

csv_fname = "callsourcecalls.csv"
csv = CSV.open( csv_fname, "r")
urls = []

csv.each do |row|
	row.each do |cell|
		if cell.is_a? String
			if cell.include? "https://calltrackdata.com/"
				urls.push cell
			end
		end
	end
end

url_count = urls.count

###check url for redirects

def getredirectedurl(url)
	result = Curl::Easy.perform(url) do |curl| 
	  curl.headers["User-Agent"] = "..."
	  curl.verbose = false
	  curl.follow_location = true
	end
	return result.last_effective_url
end

###sinatra get request handling

get %r{/.*} do
	pass if settings.c >= url_count
	Twilio::TwiML::Response.new do |r|
	    r.Say getredirectedurl(urls[settings.c])
	end.text
end

get %r{/.*} do
	pass if settings.c < url_count
	"no more files!"
end

after do
	if settings.c < url_count
		settings.c += 1
		puts "sending file #{settings.c} of #{url_count}"
	else
		puts "no more files to send!"
	end
end


