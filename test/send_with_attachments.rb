
require_relative '../lib/expresspigeon-ruby.rb'

MESSAGES = ExpressPigeon::API.messages.auth_key(ENV['AUTH_KEY'])

attachments = %W{attachments/attachment1.txt  attachments/smile.pdf attachments/example.ics}

puts MESSAGES.send_message(
    1527,                                     # template_id
    'igor@expresspigeon.com',                         #to
    'igor@polevoy.org',                         #reply_to
    "Igor Polevoy",                             #from_name
    "Hi there! Two attachments and a calendar",                                #subject
    {first_name: 'Igor', eye_color: 'blue'},    #merge_fields
    false,                                      #view_online
    true,                                       #click_tracking
    attachments                                 #file paths to upload as attachments
)
