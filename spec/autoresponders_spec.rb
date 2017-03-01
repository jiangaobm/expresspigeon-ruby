require './lib/expresspigeon-ruby'
require 'pigeon_helper'

describe 'autoresponders integration test' do

  include PigeonSpecHelper

  it 'should return all autoresponders' do
    res = ExpressPigeon::API.autoresponders.all
    res.class.should == Array
    res.size.should > 0
    puts res
  end

  it 'should start autoresponder by id' do
    res = ExpressPigeon::API.autoresponders.start 672, 'igor@polevoy.org'
    puts res
  end

  it 'should stop autoresponder by id' do
    res = ExpressPigeon::API.autoresponders.stop 672, 'igor@polevoy.org'
    puts res
  end

  it 'should get single report' do
    res = ExpressPigeon::API.autoresponders.report 672
    puts res
  end

  it 'should get bounces for autoresponder part' do
    res = ExpressPigeon::API.autoresponders.bounced 672, 746
    puts res
  end

  it 'should get spam for autoresponder part' do
    res = ExpressPigeon::API.autoresponders.spam 672, 746
    puts res
  end

  it 'should get unsubscribed for autoresponder part' do
    res = ExpressPigeon::API.autoresponders.unsubscribed 672, 746
    puts res
  end

end

