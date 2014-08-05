require 'twilio-ruby'
require 'sinatra'
require 'curl'
require 'csv'

set :c, 0

###list of urls from csv file

urls = ["https://calltrackdata.com/webreports/audio.jsp?callID=2086701093&authentication=75E0E52C2F022233FC3070FC979C7E33",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086725818&authentication=21C006EED2356B4A1D796F0DE957C6DA",
"https://calltrackdata.com/webreports/audio.jsp?callID=44609277&authentication=5D46E05C2DF139E6C4C47F16206287C1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086781467&authentication=E83484B24EC788F446EABC7F6B4049A0",
"https://calltrackdata.com/webreports/audio.jsp?callID=2086796602&authentication=3B37BCD861F88B4F8D4366E3004370B5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087158414&authentication=F0393BAF94E6C88560B814F8646963C8",
"https://calltrackdata.com/webreports/audio.jsp?callID=44826902&authentication=200DFD9505C04A4DB9A755AEB4099881",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087761316&authentication=FD67388B4061CDB9780855ED0C3F65C5",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087822193&authentication=4433268F5253F6058B45625E035BF3CD",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087908331&authentication=22F323842B97537F4788778DD0965EEF",
"https://calltrackdata.com/webreports/audio.jsp?callID=44937390&authentication=A3CDF7EB38E05125CF661CD1175AB612",
"https://calltrackdata.com/webreports/audio.jsp?callID=2087947914&authentication=FEF17D50AD9C1F018D1A4FD7CF2ED118",
"https://calltrackdata.com/webreports/audio.jsp?callID=44974283&authentication=56BAF407F32260B40C34E7D7A16A50F1",
"https://calltrackdata.com/webreports/audio.jsp?callID=2088120861&authentication=5B1FBC68EF808ACEDCA419B1CB7DB83F",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098421418&authentication=0FCCF81726FE7B3D0D61A397263619B0",
"https://calltrackdata.com/webreports/audio.jsp?callID=48107823&authentication=11FD0F5258872B1E20279AF00A464684",
"https://calltrackdata.com/webreports/audio.jsp?callID=2098613009&authentication=C76B190695F7141D22C01D4F538C3338",
"https://calltrackdata.com/webreports/audio.jsp?callID=48263784&authentication=74FDEF6D61D8D28A3D536233EEBAF4CB"]

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
