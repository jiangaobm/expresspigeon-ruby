require './lib/expresspigeon-ruby'
require 'pigeon_helper'

describe 'lists integration test' do

  include PigeonSpecHelper

  it 'test_create_and_delete_new_list(self):' do
    contact_list = ExpressPigeon::API.lists.create 'Active customers', 'Bob', 'bob@acmetools.com'
    validate_response contact_list, 200, 'success', /list=#{contact_list.list.id} created\/updated successfully/
    contact_list.list.name.should eq "Active customers"
    contact_list.list.from_name.should eq "Bob"
    contact_list.list.reply_to.should eq "bob@acmetools.com"
    contact_list.list.contact_count.should eq 0
    res = ExpressPigeon::API.lists.delete contact_list.list.id
    validate_response res, 200, 'success', /list=#{contact_list.list.id} deleted successfully/
  end

  it 'should update existing list' do
    contact_list = ExpressPigeon::API.lists.create("Update", "Bob", "bob@acmetools.com")
    res = ExpressPigeon::API.lists.update contact_list.list.id, :name => 'Updated Name', :from_name => 'Bob', :reply_to => 'Frank@zappa.com'
    validate_response res, 200, 'success', /list=#{res.list.id} created\/updated successfully/
    res.list.name.should eq "Updated Name"
    res.list.from_name.should eq 'Bob'
    res = ExpressPigeon::API.lists.delete(contact_list.list.id)
    validate_response res, 200, 'success', /list=#{contact_list.list.id} deleted successfully/
  end


  it 'should upload contacts as CSV file' do
    list_name = "Upload_#{Kernel.rand(9999).to_s}"
    list_resp = ExpressPigeon::API.lists.create(list_name, 'Bob', 'bob@acmetools.com')
    begin
      resp = ExpressPigeon::API.lists.upload(list_resp.list.id, 'spec/resources/upload.csv')
      validate_response resp, 200, 'success', /file uploaded successfully/
      res = ExpressPigeon::API.contacts.find_by_email 'x@x.x'
      res.lists[0]['id'].should eq list_resp.list.id
    ensure
      res = ExpressPigeon::API.lists.delete(list_resp.list.id)
      validate_response res, 200, 'success', /list=#{list_resp.list.id} deleted successfully/
      ExpressPigeon::API.contacts.find_by_email('x@x.x').message.should eq 'contact=x@x.x not found'
    end
  end

# it 'complete below'
#    def test_upsert_list_with_non_existent_id(self):
#        res = self.api.lists.update(-1, {"name": "Updated Name", "from_name": "Bill"})
#        self.assertEqual(res.status, "error")
#        self.assertEqual(res.code, 404)
#        self.assertEqual(res.message, "list=-1 not found")
#
#    def test_delete_list_with_non_existent_id(self):
#        res = self.api.lists.delete(-1)
#        self.assertEqual(res.status, "error")
#        self.assertEqual(res.code, 404)
#        self.assertEqual(res.message, "list=-1 not found")
#
#    def test_remove_disabled_list(self):
#        res = self.api.lists.delete(130)
#        self.assertEqual(res.code, 400)
#        self.assertEqual(res.status, "error")
#        self.assertEqual(res.message, "could not delete disabled list=130")
#
#    def test_upload_without_id(self):
#        res = self.api.lists.upload("", self.file_to_upload)
#        self.assertEqual(res.code, 400)
#        self.assertEqual(res.status, "error")
#        self.assertEqual(res.message, "you must provide list_id in URL")
#
#    def test_upload_with_non_existent_id(self):
#        res = self.api.lists.upload(-1, self.file_to_upload)
#        self.assertEqual(res.code, 404)
#        self.assertEqual(res.message, "list=-1 not found")
#
  it 'should check upload status' do
    list_response = ExpressPigeon::API.lists.create("My List", "a@a.a", "a@a.a")
    resp = ExpressPigeon::API.lists.upload(list_response.list.id, 'spec/resources/upload.csv')

    sleep 20

    begin
      puts ExpressPigeon::API.lists.upload_status list_response.list.id
    ensure
      ExpressPigeon::API.lists.delete list_response.list.id
    end

  end
#
#    def test_enabled_list_removal(self):
#        list_resp = self.api.lists.create("My list", "John", os.environ['EXPRESSPIGEON_API_USER'])
#        self.api.contacts.upsert(list_resp.list.id, {"email": os.environ['EXPRESSPIGEON_API_USER']})
#
#        now = datetime.datetime.now(pytz.UTC)
#        schedule = self.format_date(now + datetime.timedelta(hours=1))
#
#        res = self.api.campaigns.schedule(list_id=list_resp.list.id, template_id=self.template_id, name="My Campaign",
#                                          from_name="John",
#                                          reply_to=os.environ['EXPRESSPIGEON_API_USER'], subject="Hi",
#                                          google_analytics=False,
#                                          schedule_for=schedule)
#        self.assertEqual(res.code, 200)
#        self.assertEqual(res.status, "success")
#        self.assertEqual(res.message, "new campaign created successfully")
#        self.assertTrue(res.campaign_id is not None)
#
#        res = self.api.lists.delete(list_resp.list.id)
#        self.assertEqual(res.code, 400)
#        self.assertEqual(res.status, "error")
#        self.assertEqual(res.message,
#                         "could not delete list={0}, it has dependent subscriptions and/or scheduled campaigns".format(
#                             list_resp.list.id))
#
   it 'should upload and download CSV' do
     list_response = ExpressPigeon::API.lists.create("My List", "a@a.a", "a@a.a")
     resp = ExpressPigeon::API.lists.upload(list_response.list.id, 'spec/resources/upload.csv')
     res = ExpressPigeon::API.lists.csv(list_response.list.id)
     ExpressPigeon::API.lists.delete list_response.list.id

     count = 0
     res.each_line do |line|
      count = count + 1
     end
     count.should eq 4



     # self.assertEquals(len(res), 2)
       # headers = '"Email", "First name", "Last name", "City", "Phone", "Company", "Title", "Address 1", "Address 2", ' \
       #           '"State", "Zip", "Country", "Date of birth", "custom_field_1", "custom_field_10", "custom_field_11", ' \
       #           '"custom_field_12", "custom_field_13", "custom_field_18", "custom_field_19", "custom_field_2", ' \
       #           '"custom_field_20", "custom_field_21", "custom_field_22", "custom_field_23", "custom_field_24", ' \
       #           '"custom_field_3", "custom_field_4", "custom_field_5", "custom_field_6", "custom_field_7", ' \
       #           '"custom_field_8", "custom_field_9"'
       # self.assertEquals(res[0], headers)
       # self.assertEquals(res[1], '"mary@a.a",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,')
       #
       # self.api.lists.delete(list_response.list.id)
       # self.api.contacts.delete("mary@a.a")
     end

end