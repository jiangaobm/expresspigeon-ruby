PIGEON = ExpressPigeon::API

module PigeonSpecHelper
  def validate_response res, code, status, message
    res.code.should eq code
    res.status.should eq status
    if message
      (res.message =~ message).should_not be_nil
    end
  end
end

