# Expresspigeon::Ruby

This is a Ruby library for convenince access to [ExpressPigeon API](https://expresspigeon.com/api).

## Installation

Add this line to your application's Gemfile:

    gem 'expresspigeon-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install expresspigeon-ruby

## Usage

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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
