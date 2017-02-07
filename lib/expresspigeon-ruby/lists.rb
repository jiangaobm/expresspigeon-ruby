module ExpressPigeon
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
    #param list_id: Id of list to be updated
    #param type list_id: int
    #param params: JSON object represents a list to be updated

    #
    #:returns: EpResponse with status, code, message, and updated list
    #
    def update(list_id, params = {})
      post @endpoint, {:id => list_id, :name => params[:name], :from_name => params[:from_name], :reply_to => params[:reply_to]}
    end


    #
    #:returns: status of upload
    #
    def upload_status(list_id)
      get "#{@endpoint}/upload_status/#{list_id}"
    end

    ##
    # Removes a list with a given id. A list must be enabled and has no dependent subscriptions and/or scheduled campaigns.
    #
    #  param list_id: Id of list to be removed.
    #  returns response hash with status, code, and message
    def delete(list_id)
      del "#{@endpoint}/#{list_id}"
    end

    # Downloads a list as CSV file
    # :arg: list_id ID of a list to download
    def csv(list_id, &block)
      get "#{@endpoint}/#{list_id}/csv", &block
    end

    def upload(list_id, file_name)
      path = "#{@root ? @root : ROOT}/#{@endpoint}/#{list_id}/upload"
      begin
        resp = RestClient.post(path,
                              {:contacts_file => File.new(file_name)},
                              {:'X-auth-key' => get_auth_key})
        res = resp.body
      rescue RestClient::ExceptionWithResponse => err
        res = err.response # this happens even if everything is OK, but the HTTP code is 404, or something... strange
      end
      parsed = JSON.parse(res)
      if parsed.kind_of? Hash
        MetaResponse.new parsed
      else
        parsed
      end
    end

  end
end

