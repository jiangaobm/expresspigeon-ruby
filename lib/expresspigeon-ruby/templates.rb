module ExpressPigeon
  class Templates
    include ExpressPigeon::API

    def initialize
      @endpoint = 'templates'
    end

    def copy(template_id, template_name, merge_fields = {})
      post "#{@endpoint}/#{template_id}/copy", name: template_name, merge_fields: merge_fields
    end

    # Deletes existing template
    def delete(template_id)
      del "#{@endpoint}/#{template_id}"
    end
  end
end