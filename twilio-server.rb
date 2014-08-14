require 'sinatra'

###GET
get '/favicon.ico' do
	puts "We have no icons for you, shoo!"
	return "We have no icons for you, shoo!"
end

get '/get-calls' do
		puts "rejecting call"
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Reject /></Response>"
end

get '/get-twiml/*' do
		puts "sending twiml. url: http://#{params[:url]}"
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Play>http://#{params[:splat][0]}</Play><Sms>http://#{params[:splat][0]}</Sms></Response>"
end

get %r{/.*} do
	puts "Bad request: use '/get-twiml/url'"
	return "Bad request: use '/get-twiml/url'"
end

###POST
post '/reject' do
		puts "rejecting call"
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Reject /></Response>"
end

post '/get-twiml/*' do
		puts "sending twiml. url: http://#{params[:url]}"
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Play>http://#{params[:splat][0]}</Play><Sms>http://#{params[:splat][0]}</Sms></Response>"
end

post %r{/.*} do
	puts "Bad request: use '/get-twiml/url'"
	return "Bad request: use '/get-twiml/url'"
end

###HEAD
head %r{/.*} do
	puts "Attempted HEAD"
	return "HEAD AWAY FROM HERE"
end
