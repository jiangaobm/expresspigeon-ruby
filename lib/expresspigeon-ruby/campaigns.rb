module ExpressPigeon
  class Campaigns
    include ExpressPigeon::API

    def initialize
      @endpoint = 'campaigns'
    end

    def all (params ={})
      get @endpoint, params
    end

    def report(campaign_id)
      get "#{@endpoint}/#{campaign_id}"
    end

    def opened(campaign_id)
      get "#{@endpoint}/#{campaign_id}/opened"
    end

    def clicked(campaign_id)
      get "#{@endpoint}/#{campaign_id}/clicked"
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

    def delete(campaign_id)
      del "#{@endpoint}/#{campaign_id}"
    end
  end
end
