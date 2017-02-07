require './lib/expresspigeon-ruby'
require 'pigeon_helper'

describe 'templates integration test' do

  include PigeonSpecHelper

  it 'should copy template and delete template' do
    template_response = ExpressPigeon::API.templates.copy 34830, "new template", :content => "Hello Template World!"
    template_response.message.should eq 'template copied successfully'
    template_id = template_response.template_id
    delete_response = ExpressPigeon::API.templates.delete template_id
    delete_response.message.should eq 'template deleted successfully'
  end
end