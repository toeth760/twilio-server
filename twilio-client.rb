require 'twilio-ruby'
require 'csv'
require 'curb'

#ruby script can be run with or without call_data file already made. 
#there is a static file reference for the csv file containing urls to mp3's to be transcribed. (in the addurls method)
#first two methods are helpers, other four are methods to be done in this order:
#addurls => addredirects => makecalls => get transcriptions => remakecalls (optional, for failed transcriptions)
#a temporary file is made for each method and replaces call_data at the end of every method

#each method follows these steps: 1) create temporary file and/or read data from file
#2) take previos csv file's data and copy it over to new csv file
#3) take data and compute next columns data and then write it to new csv file
#4) cleanup: close, delete, rename csv files

#Notes: total time twilio takes is approximately 2-3 times the length of the longest audio file
#if program is interrupted, delete call_data_new.csv before restarting script

#authorization info for twilio
account_sid = 'AC9fa35979fae87eed73594023536ccf27'
auth_token = '6fd2527fc56e049891fe3dd59dffba53'
@client = Twilio::REST::Client.new account_sid, auth_token

#output csv file check/creation
file_check = File.exist?('call_data.csv')
$csv_old = CSV.open("call_data.csv", "ab")
if !file_check
	$csv_old << ['call_recording_url', 'redirected_url', 'callee_sid', 'transcription_text']
end
$csv_read = CSV.read('call_data.csv', :headers=>true)
$start_time = Time.now

#helper
def urlnotincsv?(url)
	$csv_read.each do |row|
		if row[0] == url
			return false
		end
	end
	return true
end

#helper
def getredirect(url)
	result = Curl::Easy.perform(url) do |curl| 
	  curl.verbose = false
	  curl.follow_location = true
	end
	return result.last_effective_url
end

#first method to be run
def addurls()
	#change this to the csv you want to retrieve urls from. urls must have a header named 'call_recording_url'
	@csv_urls = CSV.read('urls.csv', :headers=>true)
	@urls = @csv_urls['call_recording_url']
	@urls = @urls.uniq
	@urls.delete_if {|x| x == '' || x.nil?}
	@url_count = @urls.length
	# @urls.each do |url|
	for i in 0..99
		puts "Original url: #{@urls[i]}"
		if urlnotincsv?(@urls[i])
			$csv_old << [@urls[i], nil, nil, nil]
		end
	end
	$csv_old.close()
end

#second method to be run
def addredirects()
	@csv_new = CSV.open("call_data_new.csv", "ab")
	@csv_new << ['call_recording_url', 'redirected_url', 'callee_sid', 'transcription_text']
	$csv_read = CSV.read('call_data.csv', :headers=>true)
	$csv_read.each do |row|
		if row[1].nil?
			@redirect = getredirect(row[0])
			puts "Redirected url: #{@redirect}"
			@csv_new << [row[0], @redirect, nil, nil]
		else
			puts "Redirected url: #{@redirect}"
			@csv_new << row
		end
	end
	File.rename('call_data.csv', 'call_data_del.csv')
	File.rename('call_data_new.csv', 'call_data.csv')
	File.delete('call_data_del.csv')
	@csv_new.close()
end

#third method to be run
def makecalls()
	@csv_new = CSV.open("call_data_new.csv", "ab")
	@csv_new << ['call_recording_url', 'redirected_url', 'callee_sid', 'transcription_text']
	$csv_read = CSV.read('call_data.csv', :headers=>true)
	$csv_read.each do |row|
		if row[2].nil?
			caller_sid = @client.account.calls.create(:url => "http://twilio-server-new-env-7ruzsb3t6w.elasticbeanstalk.com/get-twiml/#{row[1].gsub(/https*:\/\//, '')}", :from => "+18189460978", :to => "18189460048").sid
			callee_sid = @client.account.calls.list[0].sid
			while caller_sid == callee_sid do
				callee_sid = @client.account.calls.list[0].sid
			end
			puts "Callid of callee: #{callee_sid}"
			@csv_new << [row[0], row[1], callee_sid, nil]
		else
			puts "Callid of callee: #{row[2]}"
			@csv_new << row
		end
	end
	File.rename('call_data.csv', 'call_data_del.csv')
	File.rename('call_data_new.csv', 'call_data.csv')
	File.delete('call_data_del.csv')
	@csv_new.close()
end

#final method to be called get retrieve transcriptions from twilio
def gettranscriptions()
	@csv_new = CSV.open("call_data_new.csv", "ab")
	@csv_new << ['call_recording_url', 'redirected_url', 'callee_sid', 'transcription_text']
	$csv_read = CSV.read('call_data.csv', :headers=>true)
	$csv_read.each do |row|
		puts row[2]
		if row[3].nil? || row[3].include?("%FAILED%") || row[3].empty?
			@recording = @client.account.calls.get(row[2]).recordings.list[0]
			while @recording.nil? do
				@recording = @client.account.calls.get(row[2]).recordings.list[0]
			end
			@transcription = @recording.transcriptions.list[0]
			while @transcription.nil? do
				@transcription = @recording.transcriptions.list[0]
			end
			transcription = @transcription.transcription_text
			puts "Transcription: \"#{transcription}\""
			if transcription.nil? || transcription.empty?
				@csv_new << [row[0], row[1], row[2], "%FAILED%"]
			else
				@csv_new << [row[0], row[1], row[2], transcription]
			end
		else
			puts row[3]
			@csv_new << row
		end
	end
	File.rename('call_data.csv', 'call_data_del.csv')
	File.rename('call_data_new.csv', 'call_data.csv')
	File.delete('call_data_del.csv')
	@csv_new.close()
end

#optional method to be run if twilio does not corrctly transcribe audio. (may do this when mp3's have music in them)
def remakecalls()
	@csv_new = CSV.open("call_data_new.csv", "ab")
	@csv_new << ['call_recording_url', 'redirected_url', 'callee_sid', 'transcription_text']
	$csv_read = CSV.read('call_data.csv', :headers=>true)
	$csv_read.each do |row|
		if row[3] == "%FAILED%"
			caller_sid = @client.account.calls.create(:url => "http://twilio-server-new-env-7ruzsb3t6w.elasticbeanstalk.com/get-twiml/#{row[1].gsub(/https*:\/\//, '')}", :from => "+18189460978", :to => "18189460048").sid
			callee_sid = @client.account.calls.list[0].sid
			while caller_sid == callee_sid do
				callee_sid = @client.account.calls.list[0].sid
			end
			puts "Callid of callee: #{callee_sid}"
			@csv_new << [row[0], row[1], callee_sid, nil]
		else
			puts "Callid of callee already called: #{row[2]}"
			@csv_new << row
		end
	end
	File.rename('call_data.csv', 'call_data_del.csv')
	File.rename('call_data_new.csv', 'call_data.csv')
	File.delete('call_data_del.csv')
	@csv_new.close()
end

addurls
addredirects
makecalls

#call this after running the above calls and when some time has passed. (~3 times the duration of longest mp3 input)
#gettranscriptions

#call this when there are %FAILED% strings for transcription_text. may fix some.
# remakecalls

$end_time = Time.now
puts "Time elapsed #{($end_time - $start_time)} seconds"

###example for retrieving mp3 recording: https://api.twilio.com/2010-04-01/Accounts/AC9fa35979fae87eed73594023536ccf27/Recordings/REd6779d814407af53417a3085dd651ca3.mp3
###receiver twimlbin: http://twimlbin.com/59110e80
###sender twimlbin: http://twimlbin.com/88ffa2c5
###server twimlbin: http://twimlbin.com/c6514667
###other twimlbin: http://twimlbin.com/accb5337

