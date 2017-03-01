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
    def all
      get @endpoint
    end

    # Start for a contact
    #
    # This call starts an autoresponder for a contact.
    #
    # :param auto_responder_id: autoresponder id to be started for a contact
    # :param email:             contact email
    #
    #
    def start(auto_responder_id, email)
      post "#{@endpoint}/#{auto_responder_id}/start", email: email
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
      post "#{@endpoint}/#{auto_responder_id}/stop", email: email
    end

    # Reports for a single responder
    #
    # :param auto_responder_id: autoresponder id to be stopped for a contact
    # :param email:             contact email
    #
    def report(auto_responder_id)
      get "#{@endpoint}/#{auto_responder_id}"
    end


    # Reports bounces for autoresponder part
    #
    # :param auto_responder_id: autoresponder id to be stopped for a contact
    # :param auto_responder_part_id: id of the autoresponder part in questions
    #
    def bounced(auto_responder_id, autoresponder_part_id)
      get "#{@endpoint}/#{auto_responder_id}/#{autoresponder_part_id}/bounced"
    end

    # Reports unsubscribed for autoresponder part
    #
    # :param auto_responder_id: autoresponder id to be stopped for a contact
    # :param auto_responder_part_id: id of the autoresponder part in questions
    #
    def unsubscribed(auto_responder_id, autoresponder_part_id)
      get "#{@endpoint}/#{auto_responder_id}/#{autoresponder_part_id}/unsubscribed"
    end


    # Get spam reports for autoresponder part
    #
    # :param auto_responder_id: autoresponder id to be stopped for a contact
    # :param auto_responder_part_id: id of the autoresponder part in questions
    #
    def spam(auto_responder_id, autoresponder_part_id)
      get "#{@endpoint}/#{auto_responder_id}/#{autoresponder_part_id}/spam"
    end
  end
end
