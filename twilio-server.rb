require 'sinatra'

###GET
get '/favicon.ico' do
	puts "We have no icons for you, shoo!"
	return "We have no icons for you, shoo!"
end

get '/get-twiml/:url' do
		puts "sending twiml. url: http://#{params[:url]}"
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Play>http://#{params[:url]}</Play></Response>"
end

get %r{/.*} do
	puts "Bad request: use '/get-twiml/url'"
	return "Bad request: use '/get-twiml/url'"
end

###POST
post '/get-twiml/:url' do
		puts "sending twiml. url: http://#{params[:url]}"
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Play>http://#{params[:url]}</Play></Response>"
end

###HEAD
head %r{/.*} do
	puts "Attempted HEAD"
	return "HEAD AWAY FROM HERE"
end
