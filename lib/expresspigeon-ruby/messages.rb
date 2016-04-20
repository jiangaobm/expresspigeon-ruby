module ExpressPigeon
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

      get query

    end
  end
end
