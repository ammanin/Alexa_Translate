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

  on_intent("Translate") do
    slots = request.intent.slots
    puts slots.to_s
    trans_txt = (request.intent.slots["trans_txt"])
	lang_input = (request.intent.slots["lang_input"])
	response.set_output_speech_text(trans_met(trans_txt, lang_input))  
    #response.set_simple_card("title", "content")
	send_answer(trans_met(trans_txt, lang_input))
  end
  on_intent("Options") do
	response.set_output_speech_text("Hi #{ENV["APP_USERc"]}, other than fulfilling your translation needs, ask me to quiz you about what you’ve already translated. You need to get smarter. I know not everyone can be a bot, but you can atleast try.")  
  end
  on_intent("Previous") do
  response.set_output_speech_text(revision) 
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
	message = trans_met("where are you from", "dgfdg")
	send_answer(message)
	message
end
=begin
get '/incoming_sms' do
  
  session["last_context"] ||= nil
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  
  body = body.downcase.strip
  
  if session["last_context"] = "quiz"
	ans = body
		if session["answer"] = ans
			("I'm impressed. You are smarter than you look")  
		else
			("Wrong! Really?")
		end
  elsif	body = "quiz" & session{["last_context"]} != "quiz"
	question = TranList.sample.first
	message  = "what does #{question.tras} mean" 
	session["answer"] = question.transtxt
   else 
   message = "Something went wrong! Try again"
  end
  
      
  twiml = Twilio::TwiML::Response.new do |resp|
    resp.Message message
  end
    
  return twiml.text
end

	session["counter"] ||= nil
	if  session["last_context"] = "quiz"
		
		
		session["last_context"] = "not playing"
	else

		
	#end
  end
=end
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
 	langinput = langinput.downcase.strip.to_s
 if LangList.exists?(:lang_name => langinput)
	translator = BingTranslator.new(ENV["MICROSOFT_CLIENT_ID"], ENV["MICROSOFT_CLIENT_SECRET"]) 
	langcd = LangList.find_by lang_name: langinput 
	tranoutput = translator.translate(transtxt, :from => 'en', :to => langcd.lang_code)
	if !TranList.exists?(:tras => tranoutput)
		update = TranList.create(lang: langinput, phrase: transtxt, tras: tranoutput)
		update.save
	end
  "#{transtxt} in #{langinput} is #{tranoutput}"
  else
  "Sorry. I do not know that language. What do you expect? I am, but a simple bot."
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
def revision
	revise = TranList.sample.first
	"#{revise.phrase} in #{revise.lang} is #{revise.tras}"
end