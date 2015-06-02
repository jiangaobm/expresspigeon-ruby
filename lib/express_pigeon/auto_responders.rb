module ExpressPigeon
  class AutoResponders
    include ExpressPigeon::API

    def initialize
      @endpoint = 'auto_responders'
    end

    attr_reader :endpoint

    # Get all autoresponders
    #
    # Returns an array of autoresponders.
    #
    # Docs: https://expresspigeon.com/api#auto_responders_get_all
    #
    def all
      get endpoint
    end

    # Start for a contact
    #
    # This call starts an autoresponder for a contact.
    #
    # :param auto_responder_id: autoresponder id to be started for a contact
    # :param email:             contact email
    #
    # Docs: https://expresspigeon.com/api#auto_responders_start
    #
    def start(auto_responder_id, email)
      post "#{endpoint}/#{auto_responder_id}/start", email: email
    end

    # Stop for a contact
    #
    # This call stops an autoresponder for a contact.
    #
    # :param auto_responder_id: autoresponder id to be stopped for a contact
    # :param email:             contact email
    #
    # Docs: https://expresspigeon.com/api#auto_responders_stop
    #
    def stop(auto_responder_id, email)
      post "#{endpoint}/#{auto_responder_id}/stop", email: email
    end
  end
end
