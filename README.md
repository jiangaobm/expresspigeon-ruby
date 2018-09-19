# Expresspigeon::Ruby

This is a Ruby library for convenient access to [ExpressPigeon API](https://expresspigeon.com/api).

## Installation

Add this line to your application's Gemfile:

    gem 'expresspigeon-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install expresspigeon-ruby

## Sending a simple message

Sending a transactional message is easy: 

```ruby
MESSAGES = ExpressPigeon::API.messages.auth_key 'XXX'
message_response = MESSAGES.send_message 115,                 # template ID
                                         'to_john@doe.com',   # send to
                                         'from_jane@doe.com', # reply to
                                         "Jane Dow",          # senders name
                                         'Hi there!',         # subject
                                                              # hash with custom content to merge
                                         content: "hello, there!"

puts message_response

# need to wait before message information is written to DB
sleep 5  

# get a report for a specific message
puts MESSAGES.report message_response.id
```

## Sending a message with attachments

```ruby
 MESSAGES = ExpressPigeon::API.messages.auth_key(ENV['AUTH_KEY'])

 attachments = %W{attachments/attachment1.txt  attachments/smile.pdf attachments/example.ics}

 puts MESSAGES.send_message(
     123,                                        # template_id
     'john@doe.com',                             #to
     'jane@doe.com',                             #reply_to
     "Jane Doe",                                 #from
     "Want to get out for a dinner?",            #subject
     {first_name: 'John', main_course: 'stake'}, #merge_fields
     false,                                      #view_online
     true,                                       #click_tracking
     true,                                       #suppress_address
     attachments                                 #file paths to upload as attachments
 )

```

## Sending a message with all required and optional arguments

```ruby

MESSAGES = ExpressPigeon::API.messages.auth_key(ENV['AUTH_KEY'])

attachments = %W{attachments/attachment1.txt attachments/calendar.ics}

puts MESSAGES.send_msg 123, 'john@doe.com', 'jane@doe.com',
                       'Jane Doe', 'A simple test subject',
                       merge_fields: { first_name: "John" },
                       view_online: false,
                       click_tracking: true,
                       suppress_address: false,
                       attachments: attachments,
                       headers: { Xtest: "test" },
                       reply_name: "Jane S. Doe",
                       from_address: "jane+123@doe.com" 

```

The first five arguments are mandatory, while the rest are optional. 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
