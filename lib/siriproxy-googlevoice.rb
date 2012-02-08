require 'cora'
require 'siri_objects'
require 'google_text'

#######
# This is a plugin for sending Google Voice SMS messages.
# Edit to your heart's content!
# 
# Created by Jacob Williams
######

class SiriProxy::Plugin::GoogleVoice < SiriProxy::Plugin
def initialize(config)
   @gusername = config['gusername']
   @gpassword = config['gpassword']
end
   listen_for /(message|text) using Google Voice/i do
      GoogleText.configure do |config|
         config.email = @gusername+'@gmail.com'
         config.password = @gpassword
      end
      gvnumber = ask "What number?"
      gvmessage = ask "What should it say?"
      say "New message to #{gvnumber}"
      say "It says: #{gvmessage}"
      confirm = ask "Ready to send?"
      if confirm =~ /yes/i
         message = GoogleText::Message.new(:text => "#{gvmessage}", :to => "#{gvnumber}")
         message.send
         if message.sent?
            say "Message sent!"
         else
            say "I'm sorry but I couldn't send your message.."
         end
      else
         say "OK. Cancelling..."
      end
      request_completed
   end
   listen_for /Google Voice messages/i do
      GoogleText.configure do |config|
         config.email = @gusername+'@gmail.com'
         config.password = @gpassword
      end
      messages = GoogleText::Message.unread
      until messages == []
         message = messages.first
         say "This message is from #{messages.from}. It says:"
         say "'#{messages.text}'"
         message.mark_as_read
         messages = GoogleText::Message.unread
      end
      request_completed
   end
end
