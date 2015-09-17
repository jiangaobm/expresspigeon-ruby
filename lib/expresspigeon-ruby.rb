require "expresspigeon-ruby/version"

require 'net/http'
require 'json'
require 'uri'
require 'rest_client'

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

      req['X-auth-key'] = get_auth_key
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

    def get_auth_key
      unless AUTH_KEY ||  @auth_key
        raise("Must set authentication key either using environment variable EXPRESSPIGEON_AUTH_KEY, or using auth_key() method in code")
      end

      @auth_key ? @auth_key : AUTH_KEY
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

    def self.templates
      Templates.new
    end
  end

end

require_relative 'expresspigeon-ruby/meta_hash'
require_relative 'expresspigeon-ruby/lists'
require_relative 'expresspigeon-ruby/campaigns'
require_relative 'expresspigeon-ruby/contacts'
require_relative 'expresspigeon-ruby/messages'
require_relative 'expresspigeon-ruby/templates'

require_relative 'express_pigeon/auto_responders'
