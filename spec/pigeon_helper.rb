
TEMPLATE_ID = ENV['TEMPLATE_ID']
LIST_ID = ENV['LIST_ID']
API_USER = ENV['API_USER']

module PigeonSpecHelper
  def validate_response res, code, status, message
    res.code.should eq code
    res.status.should eq status
    if message
      (res.message =~ message).should_not be_nil
    end
  end
end

