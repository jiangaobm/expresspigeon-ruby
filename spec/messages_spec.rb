require './lib/expresspigeon-ruby'
require 'pigeon_helper'

describe 'transactional messages integration test' do

  include PigeonSpecHelper

  #def test_sending_message_and_report_without_params(self):
  #    res = self.api.messages.send_message(template_id=-1, to="", reply_to="", from_name="", subject="")
  #    self.assertEqual(res.code, 400)
  #    self.assertEqual(res.status, "error")
  #    self.assertEqual(res.message, "Required fields: template_id, reply_to, from, to, and subject")
  #
  #def test_sending_message_and_report_with_wrong_email_in_to(self):
  #    res = self.api.messages.send_message(template_id=-1, to="e", reply_to="a@a.a", from_name="me", subject="Hi")
  #    self.assertEqual(res.code, 400)
  #    self.assertEqual(res.status, "error")
  #    self.assertEqual(res.message, "Email in the 'to' field is not valid")
  #
  #def test_sending_message_and_report_with_wrong_email_in_reply_to(self):
  #    res = self.api.messages.send_message(template_id=-1, to="e@e.e", reply_to="a", from_name="me", subject="Hi")
  #    self.assertEqual(res.code, 400)
  #    self.assertEqual(res.status, "error")
  #    self.assertEqual(res.message, "Email in the 'reply_to' field is not valid")
  #
  #def test_sending_message_and_report_with_wrong_template_id(self):
  #    res = self.api.messages.send_message(template_id=-1, to="e@e.e", reply_to="a@a.a", from_name="me", subject="Hi")
  #    self.assertEqual(res.code, 400)
  #    self.assertEqual(res.status, "error")
  #    self.assertEqual(res.message, "template=-1 not found")


  #TODO: complete the spec
  it 'sends a single transactional message' do
    message_response = PIGEON.messages.send_message 115, ENV['TARGET_EMAIL'], ENV['TARGET_EMAIL'], "Team ExpressPigeon", "Hi there!",
                                                    :first_name => "Igor"
    validate_response message_response, 200, 'success', /email queued/
    report = PIGEON.messages.report(message_response.id)
    report.id.should eq message_response.id
  end


  #
  #def test_reports_with_bad_dates(self):
  #    res = self.api.messages.reports("abc", "")
  #    self.assertEquals(res.code, 400)
  #    self.assertEquals(res.status, "error")
  #    self.assertEquals(res.message, "invalid 'start_date' or 'end_date'")
  #
  #def test_reports_with_start_date_only(self):
  #    res = self.api.messages.reports("2013-03-16T11:22:23.210+0000", "")
  #    self.assertEquals(res.code, 400)
  #    self.assertEquals(res.status, "error")
  #    self.assertEquals(res.message, "'start_date' and 'end_date' should be provided together")
  #
  #def test_reports_with_end_date_only(self):
  #    res = self.api.messages.reports("", "2013-03-16T11:22:23.210+0000")
  #    self.assertEquals(res.code, 400)
  #    self.assertEquals(res.status, "error")
  #    self.assertEquals(res.message, "'start_date' and 'end_date' should be provided together")
  #
  #def test_sending_multiple_messages_and_get_reports(self):
  #    message_response = self.api.messages.send_message(template_id=self.template_id,
  #                                                      to=os.environ['EXPRESSPIGEON_API_USER'],
  #                                                      reply_to="a@a.a", from_name="me", subject="Hi",
  #                                                      merge_fields={"first_name": "Gleb"})
  #    self.assertEqual(message_response.code, 200)
  #    self.assertEqual(message_response.status, "success")
  #    self.assertEqual(message_response.message, "email queued")
  #    self.assertTrue(message_response.id is not None and message_response.id != "")
  #
  #    message_response_2 = self.api.messages.send_message(template_id=self.template_id,
  #                                                        to=os.environ['EXPRESSPIGEON_API_USER'],
  #                                                        reply_to="a@a.a", from_name="me", subject="Hi 2",
  #                                                        merge_fields={"first_name": "Gleb"})
  #    self.assertEqual(message_response_2.code, 200)
  #    self.assertEqual(message_response_2.status, "success")
  #    self.assertEqual(message_response_2.message, "email queued")
  #    self.assertTrue(message_response_2.id is not None and message_response.id != "")
  #
  #    report = self.__get_report_by_id__(message_response.id)
  #
  #    self.assertEquals(report.id, message_response.id)
  #    self.assertEquals(report.email, os.environ['EXPRESSPIGEON_API_USER'])
  #    self.assertTrue(report.in_transit is not None)
  #
  #    report2 = self.__get_report_by_id__(message_response_2.id)
  #
  #    self.assertEquals(report2.id, message_response_2.id)
  #    self.assertEquals(report2.email, os.environ['EXPRESSPIGEON_API_USER'])
  #    self.assertTrue(report2.in_transit is not None)
  #
  it 'test_sending_multiple_messages_and_get_reports_for_today(self):' do

    start = Time.now.utc - 60 # one minute ago

    message_response = PIGEON.messages.send_message 4905, ENV['TARGET_EMAIL'], ENV['TARGET_EMAIL'],
                                                    'Team EP', "Hi, there!", :first_name => "Bob"

    validate_response message_response, 200, 'success', /email queued/
    message_response.id should_not be_nil

    message_response2 = PIGEON.messages.send_message 4905, ENV['TARGET_EMAIL'], ENV['TARGET_EMAIL'],
                                                     'Team EP', "Hi, there!", :first_name => "Bob"
    validate_response message_response2, 200, 'success', /email queued/
    message_response2.id should_not be_nil

    finish = start + 120 # two minutes after start
    reports = PIGEON.messages.reports (message_response.id - 1), start, finish

    reports.size.should eq 2
    reports[0]['id'].should eq message_response.id
    reports[1]['id'].should eq message_response2.id

    reports[0]['email'].should eq ENV['TARGET_EMAIL']
    reports[1]['email'].should eq ENV['TARGET_EMAIL']
  end
  #
  #def __get_report_by_id__(self, message_id, start_date=None, end_date=None):
  #    reports = self.api.messages.reports() if start_date is None and end_date is None else \
  #        self.api.messages.reports(start_date, end_date)
  #    report = [r for r in reports if r.id == message_id]
  #    self.assertEquals(len(report), 1)
  #    return report[0]


  it 'should from payload hash' do

     payload = PIGEON.messages.prepare_payload(123,           #template_id
                                               'john@doe.com',
                                               'jane@doe.com',
                                               'Jane Doe',
                                               'Hello, Dolly!',
                                               {eye_color: 'blue', body_shape:'pear'},
                                               false, true, false,
                                               %w(spec/resources/attachment1.txt spec/resources/attachment2.txt))

     payload[:multipart].should eq true
     payload[:template_id].should eq 123
     payload[:to].should eq 'john@doe.com'
     payload[:reply_to].should eq 'jane@doe.com'
     payload[:from].should eq 'Jane Doe'
     payload[:subject].should eq 'Hello, Dolly!'
     payload[:template_id].should eq 123
     payload[:merge_fields][:eye_color].should eq 'blue'
     payload[:merge_fields][:body_shape].should eq 'pear'
     payload[:view_online].should eq false
     payload[:click_tracking].should eq true
     payload[:suppress_address].should eq false
     payload['attachment1.txt'].class.should eq File
     File.basename(payload['attachment1.txt']).should eq 'attachment1.txt'
     File.basename(payload['attachment2.txt']).should eq 'attachment2.txt'
  end
end