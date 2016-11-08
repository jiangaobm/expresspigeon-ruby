module ExpressPigeon
  class Messages

    include ExpressPigeon::API

    def initialize
      @endpoint = 'messages'
    end

    # Sends a transactional message using ExpressPigeon Rest API
    #
    # * +template_id+ - ID of a template to use for sending
    # * +to+ - destination email address
    # * +reply_to+ - return email address
    # * +from_name+ - name of sender
    # * +subject+ - subject of email
    # * +merge fields+ - hash with dynamic values to merge into a template
    # * +view_online+ - generate "view online" link in the template
    # * +click_tracking+ - enable/disable click tracking (and URL rewriting)
    # * +attachments+ - array of file paths  to attach to email. Size limit: 1k per attachment, maximum 3 attachments.
    def send_message(template_id, to, reply_to, from_name, subject, merge_fields = nil, view_online = false, click_tracking = true, attachments = nil)
      if attachments
        upload(template_id, to, reply_to, from_name, subject, merge_fields, view_online, click_tracking, attachments)
        else
          post @endpoint, params = {template_id: template_id, :to => to, reply_to: reply_to, :from => from_name, :subject => subject,
                                    :merge_fields => merge_fields, :view_online => view_online, :click_tracking => click_tracking}
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
    # This method  is not used directly, instead use +send_message()+
    #
    # * +template_id+ - ID of a template to use for sending
    # * +to+ - destination email address
    # * +reply_to+ - return email address
    # * +from_name+ - name of sender
    # * +subject+ - subject of email
    # * +merge fields+ - hash with dynamic values to merge into a template
    # * +view_online+ - generate "view online" link in the template
    # * +click_tracking+ - enable/disable click tracking (and URL rewriting)
    # * +attachments+ - array of file paths  to attach to email. Size limit: 1k per attachment, maximum 3 attachments.
    def upload(template_id, to, reply_to, from_name, subject, merge_fields, view_online, click_tracking, attachments)

      path = "#{@root ? @root : ROOT}/#{@endpoint}"

      puts "sending to #{path}"

      begin
        payload = prepare_payload(template_id, to, reply_to, from_name, subject, merge_fields, view_online, click_tracking, attachments)
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


    def prepare_payload(template_id, to, reply_to, from, subject, merge_fields, view_online, click_tracking, attachments)
      payload = { multipart: true }
      payload[:template_id] = template_id
      payload[:to] = to
      payload[:reply_to] = reply_to
      payload[:subject] = subject
      payload[:from] = from
      payload[:merge_fields] = merge_fields
      payload[:view_online] = view_online
      payload[:click_tracking] = click_tracking

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
