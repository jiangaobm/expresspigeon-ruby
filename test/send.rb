
require_relative '../lib/expresspigeon-ruby.rb'

MESSAGES = ExpressPigeon::API.messages.auth_key(ENV['AUTH_KEY'])


puts MESSAGES.send_message(
    390243,                                     # template_id
    'igor@expressxxxx.com',                         #to
    'igor@polevoyxxx.org',                         #reply_to
    "Igor Polevoy",                             #from_name
    "Hi there! A simple send 345!",             #subject
    {first_name: 'Igor', eye_color: 'brown'},   #merge_fields
    true,                                       #view_online
    true,                                       #click_tracking
    true                                       #suppress_address
    
)
