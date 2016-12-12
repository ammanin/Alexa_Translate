require "sinatra"
require 'json'
require 'sinatra/activerecord'
require 'twilio-ruby'
require 'alexa_skills_ruby'
require 'rake'
require 'haml'
require 'iso8601'
require 'ruby_gem'
require 'bing_translator'


# ----------------------------------------------------------------------

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end

# require any models 
# you add to the folder
# using the following syntax:
# require_relative './models/<model_name>'
require_relative './models/lang_list'
require_relative './models/tran_list'
# enable sessions for this project
enable :sessions


#translation API --- used inside each def function
#translator = BingTranslator.new(ENV["MICROSOFT_CLIENT_ID"], ENV["MICROSOFT_CLIENT_SECRET"])
#client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

# ----------------------------------------------------------------------
#     AlexaSkillsRuby Handler
#     See https://github.com/DanElbert/alexa_skills_ruby
# ----------------------------------------------------------------------

class CustomHandler < AlexaSkillsRuby::Handler
=begin
  on_intent("GetCurrentStatus") do
    #slots = request.intent.slots
    
    current_status = StatusUpdate.all.last.message
    
    response.set_output_speech_text("It looks like: #{current_status} ")
    #response.set_simple_card("title", "content")
    logger.info 'GetCurrentStatus processed'
    
  end
  
  on_intent("AMAZON.HelpIntent") do
    #slots = request.intent.slots
    response.set_output_speech_text("You can ask me to tell you the current out of office status by saying current status. You can update your stats by saying tell out of office i'll be right back, i've gone home, i'm in a meeting, i'm here or i'll be back in 10 minutes")
    #response.set_simple_card("title", "content")
    logger.info 'GetCurrentStatus processed'
    
  end
  
  on_intent("BeRightBack") do
    response.set_output_speech_text("I've updated your status to be right back ")
    #response.set_simple_card("title", "content")
    logger.info 'BeRightBack processed'
    update_status "brb"
  end
  
  on_intent("GoneHome") do
    response.set_output_speech_text("I've updated your status to Gone Home ")
    #response.set_simple_card("title", "content")
    logger.info 'GoneHome processed'
    update_status "home"
  end
  
  on_intent("InAMeeting") do
    response.set_output_speech_text("I've updated your status to In a meeting ")
    #response.set_simple_card("title", "content")
    logger.info 'InAMeeting processed'
    update_status "meeting"
  end
  
  
  on_intent("Here") do
    response.set_output_speech_text("I've updated your status to Here ")
    #response.set_simple_card("Out of Office App", "Status is now.")
    logger.info 'Here processed'
    update_status "here"
  end
=end
  on_intent("Translate") do
    slots = request.intent.slots
    puts slots.to_s
    trans_txt = (request.intent.slots["trans_txt"])
	lang_input = (request.intent.slots["lang_input"])
	response.set_output_speech_text(trans_met(trans_txt, lang_input))  
    #response.set_simple_card("title", "content")
	send_answer(trans_met(trans_txt, lang_input))
  end

end

# ----------------------------------------------------------------------
#     ROUTES, END POINTS AND ACTIONS
# ----------------------------------------------------------------------
post '/' do

  content_type :json

  handler = CustomHandler.new(application_id: ENV['ALEXA_APPLICATION_ID'], logger: logger)

  begin
    handler.handle(request.body.read)
		rescue AlexaSkillsRuby::InvalidApplicationId => e
		logger.error e.to_s
		403
		end
	end 

# Using this to test locally
get '/' do
	message = trans_met("where are you from", "french")
	send_answer(message)
	message
end

# ----------------------------------------------------------------------
#     ERRORS
# ----------------------------------------------------------------------

error 401 do 
  "Who goes there?"
end

# ----------------------------------------------------------------------
#   METHODS
#   Add any custom methods below
# ----------------------------------------------------------------------


private


def trans_met transtxt, langinput
  if LangList.exists?(:lang_name => langinput)
  translator = BingTranslator.new(ENV["MICROSOFT_CLIENT_ID"], ENV["MICROSOFT_CLIENT_SECRET"])
  langinput = langinput.downcase.strip.to_s
  langcd = LangList.find_by lang_name: langinput 
  tranoutput = translator.translate(transtxt, :from => 'en', :to => langcd.lang_code)
	#if !TranList.exists?(:lang => langinput) & !TranList.exists?(:tras => tranoutput)
	#update = TranList.create(lang: langinput, phrase: transtxt, tras: tranoutput)
	#update.save
	#end
  "#{transtxt} in #{langinput} is \'#{tranoutput}\'"
  else
  "Sorry. That language is foreign to me. What do you expect? I am, but a simple bot."
  end
  
end
def send_answer trans_answer
	client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
	client.account.messages.create(
	:from => ENV["TWILIO_NUMBER"],
	:to => "+14129548714",
	:body => trans_answer
	)
end
def multip int1, int2
	int1 + int2
end