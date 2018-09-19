module ExpressPigeon
  class Messages

    include ExpressPigeon::API

    def initialize
      @endpoint = 'messages'
    end

    # Sends a single transactional message.
    #
    # For more information on arguments, see: [https://expresspigeon.com/kb/transactional-send].
    #
    def send_message(template_id, to, reply_to, from, subject, merge_fields = nil, view_online = false,
                                            click_tracking = true, suppress_address = false, attachments = nil, headers = nil)
      if attachments
          upload(template_id, to, reply_to, from, subject, merge_fields, view_online, click_tracking,
                                                                                    suppress_address, attachments, headers, nil, nil)
        else
          post @endpoint, params = {template_id: template_id, to: to, reply_to: reply_to, from: from,
                                    subject: subject, merge_fields: merge_fields, view_online: view_online,
                                    click_tracking: click_tracking, suppress_address: suppress_address, headers: headers}
      end
    end


    # Sends a single transactional message.
    #
    # For more information on arguments, see: [https://expresspigeon.com/kb/transactional-send].

    # This method allows to specify different 'reply_to', 'reply_name', 'from' and 'from_address' values.
    #
    def send_msg(template_id, to, reply_to, from, subject, optional = {})

      if optional[:attachments]
        upload(template_id, to, reply_to, from, subject, optional[:merge_fields], optional[:view_online], optional[:click_tracking],
               optional[:suppress_address], optional[:attachments], optional[:headers], optional[:reply_name], optional[:from_address])
      else
        params =  optional ? optional.clone : {}
        params[:template_id] =  template_id
        params[:to] =  to
        params[:reply_to] =  reply_to
        params[:from] =  from
        params[:subject] =  subject

        post @endpoint, params
      end
    end

    # Retrieve report for a single message.
    #
    # * +message_id+ - ID of a message sent previously
    def report(message_id)
      get "#{@endpoint}/#{message_id}"
    end

    # Report for a group of messages in a given time period.
    #
    # * +start_date+ is instance of Time
    # * +end_date+ is instance of Time
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

      get query
    end


    # Sends a transactional message with attachments using ExpressPigeon Rest API.
    # This method  is not used directly, instead use +send_message()+ or +send_msg()+
    #
    # * +template_id+ - ID of a template to use for sending
    # * +to+ - destination email address
    # * +reply_to+ - return email address
    # * +from+ - name of sender
    # * +subject+ - subject of email
    # * +merge fields+ - hash with dynamic values to merge into a template
    # * +view_online+ - generate "view online" link in the template
    # * +click_tracking+ - enable/disable click tracking (and URL rewriting)
    # * +suppress_address+ - enable/disable display of physical address at the bottom of newsletter.
    # * +attachments+ - array of file paths  to attach to email.
    # * +headers+ - hash of headers to add to SMTP message
    # * +reply_name+ - reply name to use in the +reply-to+ header.
    # * +from_name+ - name to use in the +from+ header
    #
    def upload(template_id, to, reply_to, from, subject, merge_fields, view_online, click_tracking, suppress_address, attachments, headers, reply_name, from_address)
      path = "#{@root ? @root : ROOT}/#{@endpoint}"
      begin
        payload = prepare_payload(template_id, to, reply_to, from, subject, merge_fields, view_online, click_tracking, suppress_address, attachments, headers, reply_name, from_address)
        request = RestClient::Request.new(
            :method => :post,
            :headers => {:'X-auth-key' => get_auth_key},
            :url => path,
            :payload => payload)
        resp = request.execute
        res = resp.body
      rescue RestClient::ExceptionWithResponse => err
        res = err.response
      end

      parsed = JSON.parse(res)
      if parsed.kind_of? Hash
        MetaResponse.new parsed
      else
        parsed
      end
    end


    def prepare_payload(template_id, to, reply_to, from, subject, merge_fields, view_online, click_tracking, suppress_address, attachments, headers,
                        reply_name, from_address)
      payload = { multipart: true }
      payload[:template_id] = template_id
      payload[:to] = to
      payload[:reply_to] = reply_to
      payload[:subject] = subject
      payload[:from] = from
      payload[:merge_fields] = merge_fields.to_json
      payload[:headers] = headers.to_json
      payload[:view_online] = view_online
      payload[:click_tracking] = click_tracking
      payload[:suppress_address] = suppress_address
      payload[:reply_name] = reply_name
      payload[:from_address] = from_address

      attachments.each { |attachment|
        if File.file?(attachment)
          file = File.basename(attachment)
          payload[file] = File.new attachment
        else
          raise "File #{attachment} does not exist"
        end
      }
      payload
    end
  end
end
