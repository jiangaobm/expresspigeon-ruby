require "expresspigeon-ruby/version"

require 'net/http'
require 'json'
require 'uri'

module ExpressPigeon

  AUTH_KEY = ENV['EXPRESSPIGEON_AUTH_KEY']
  ROOT = 'https://api.expresspigeon.com/'
  USE_SSL = true

  module API

    # Override environment variable in code.
    def auth_key(auth_key)
      @auth_key = auth_key
      self
    end

    def root(root)
      @root = root
      self
    end

    def http(path, method, params = {})
      root = @root ? @root : ROOT
      uri = URI.parse "#{root}#{path}"
      req = Net::HTTP.const_get("#{method}").new "#{ROOT}#{path}"
      unless AUTH_KEY ||  @auth_key
        raise("Must set either EXPRESSPIGEON_AUTH_KEY as environment variable, or ExpressPigeon::AUTH_KEY in code")
      end

      req['X-auth-key'] = AUTH_KEY ? AUTH_KEY : @auth_key
      if params
        req.body = params.to_json
        req['Content-type'] = 'application/json'
      end

      if block_given?
        Net::HTTP.start(uri.host, uri.port, :use_ssl => USE_SSL) do |http|
          http.request req do |res|
            res.read_body do |seg|
              yield seg
            end
          end
        end
      else
        resp = Net::HTTP.start(uri.host, uri.port, :use_ssl => USE_SSL) do |http|
          http.request req
        end
        parsed = JSON.parse(resp.body)
        if parsed.kind_of? Hash
          MetaHash.new parsed
        else
          parsed
        end
      end
    end

    def get(path, &block)
      http path, 'Get', nil, &block
    end

    def post(path, params = {})
      http path, 'Post', params
    end

    def del(path, params = {})
      http path, 'Delete', params
    end

    def self.campaigns
      Campaigns.new
    end

    def self.lists
      Lists.new
    end

    def self.contacts
      Contacts.new
    end

    def self.messages
      Messages.new
    end

    def self.auto_responders
      AutoResponders.new
    end
  end

end

class MetaHash < Hash

  def initialize(delegate)
    super
    @delegate = delegate
    @delegate.each_key do |k|
      v = @delegate[k] # lets go only one level down for now
      if v.kind_of? Hash
        @delegate[k] = MetaHash.new(v)
      end
    end
  end

  def method_missing(m, *args, &block)
    @delegate[m.to_s]
  end

  def to_s
    @delegate.to_s
  end

  def inspect
    @delegate.inspect
  end
end

class Lists

  include ExpressPigeon::API

  def initialize
    @endpoint = 'lists'
  end

  def create(list_name, from_name, reply_to)
    post @endpoint, {:name => list_name, :from_name => from_name, :reply_to => reply_to}
  end


  # Query all lists.
  # returns: array of hashes each representing a list for this user
  def all
    get @endpoint
  end


  #Updates existing list
  #
  #:param list_id: Id of list to be updated
  #:type list_id: int
  #
  #:param params: JSON object represents a list to be updated

  #
  #:returns: EpResponse with status, code, message, and updated list
  #:rtype: EpResponse
  #TODO: resolve API on Python side, then implement this
  #def update(list_id, params = {})
  #    params['id'] = list_id
  #    return self.ep.put(self.endpoint, params=params)
  #end


  # Removes a list with a given id. A list must be enabled and has no dependent subscriptions and/or scheduled campaigns.
  #
  #  param list_id: Id of list to be removed.
  #  returns response hash with status, code, and message
  def delete(list_id)
    del "#{@endpoint}/#{list_id}"
  end

  def csv(list_id, &block)
    get "#{@endpoint}/#{list_id}/csv", &block
  end


end

class Campaigns
  include ExpressPigeon::API

  def initialize
    @endpoint = 'campaigns'
  end

  def all
    get @endpoint
  end

  def report(campaign_id)
    get "#{@endpoint}/#{campaign_id}"
  end

  def bounced(campaign_id)
    get "#{@endpoint}/#{campaign_id}/bounced"
  end

  def unsubscribed(campaign_id)
    get "#{@endpoint}/#{campaign_id}/unsubscribed"
  end

  def spam(campaign_id)
    get "#{@endpoint}/#{campaign_id}/spam"
  end

  #
  # Schedules a new campaign to be sent.
  # Parameters:
  # * *list_id* - id of list to send to
  # * *template_id* - id of template to send
  # * *name* - name of a newly created campaign
  # * *from_name* - from name
  # * *reply_to* - reply to
  # * *subject* - subject of campaign
  # * *google_analytics* - true to turn Google Analytics on
  def send(params = {})
    post @endpoint, params
  end

  #
  # Schedules a new campaign to be sent.
  # Parameters:
  # * *list_id* - id of list to send to
  # * *template_id* - id of template to send
  # * *name* - name of a newly created campaign
  # * *from_name* - from name
  # * *reply_to* - reply to
  # * *subject* - subject of campaign
  # * *google_analytics* - true to turn Google Analytics on
  # * *schedule_for* - Specifies what time a campaign should be sent. If it is provided the campaign will
  #                     be scheduled to this time, otherwise campaign is sent immediately. The schedule_for
  #                     must be in ISO date format and should be in the future.
  def schedule(params = {})
    post @endpoint, params
  end
end


class Contacts
  include ExpressPigeon::API

  def initialize
    @endpoint = 'contacts'
  end

  def find_by_email(email)
    get "#{@endpoint}?email=#{CGI.escape(email)}"
  end


  # JSON document represents a contact to be created or updated.
  # The email field is required.
  # When updating a contact, list_id is optional,
  # since the contact is uniquely identified by email across all lists.
  #
  # :param list_id: Contact list ID (Fixnum) the contact will be added to
  #
  # :param contact: Hash describes new contact. The "email" field is required.
  #
  # :returns: representation of a contact
  #
  def upsert(list_id, contact)
    post @endpoint, params = {:list_id => list_id, :contacts => [contact]}
  end

  # Delete single contact. If list_id is not provided, contact will be deleted from system.
  # :param email: contact email to be deleted.
  # :param list_id: list id to remove contact from, if not provided, contact will be deleted from system.
  def delete(email, list_id = nil)
    query  = "email=#{CGI.escape(email)}"
    query += "&list_id=#{list_id}" if list_id

    del "#{@endpoint}?#{query}", nil
  end


end
class Messages

  include ExpressPigeon::API

  def initialize
    @endpoint = 'messages'
  end

  def send_message(template_id, to, reply_to, from_name, subject, merge_fields = nil, view_online = false, click_tracking = true)
    post @endpoint, params = {template_id: template_id, :to => to, reply_to: reply_to, :from => from_name, :subject => subject,
                              :merge_fields => merge_fields, :view_online => view_online, :click_tracking => click_tracking}
  end

  def report(message_id)
    get "#{@endpoint}/#{message_id}"
  end

  #
  #
  # start_date is instance of Time
  # end_date is instance of Time
  def reports(from_id, start_date = nil, end_date = nil)
    params = []

    if from_id
      params << "from_id=#{from_id}"
    end

    if start_date and not end_date
      raise 'must include both start_date and end_date'
    end
    if end_date and not start_date
      raise 'must include both start_date and end_date'
    end

    if start_date and end_date
      params << "start_date=#{start_date.strftime('%FT%T.%L%z')}"
      params << "end_date=#{end_date.strftime('%FT%T.%L%z')}"
    end

    query = "#{@endpoint}?"

    if params.size > 0
      query << params.join('&')
    end

    puts "calling: #{query}"
    get query

  end
end

require_relative 'express_pigeon/auto_responders'
