require File.dirname(__FILE__) + '/spec_helper'

describe 'Voicemail Api' do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  def encode_credentials(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end

  before(:all) do
    User.stub!(:count).and_return(1)
    @vm = Factory(:voicemail, :mailboxuser => '1000', :recording => 'dummytext')
  end

  describe 'GET /voicemails' do
    def do_get
      get '/voicemails', {}, {'HTTP_AUTHORIZATION'=> encode_credentials('1000', '1234')}
      last_response.should be_ok
    end

    it 'should return the list of voicemails of the current user' do
      Voicemail.should_receive(:all).with(:select => "id, dir, context, callerid, origtime, duration", :conditions => {:mailboxuser => '1000'}).and_return([@vm])
      do_get
      last_response.body.should == [@vm].to_json
    end
  end

  describe 'GET /voicemails/:id' do
    def do_get
      get "/voicemails/#{@vm.id}", {}, {'HTTP_AUTHORIZATION'=> encode_credentials('1000', '1234')}
      last_response.should be_ok
    end

    it 'should fetch the voicemail' do
      Voicemail.should_receive(:find).with(@vm.id, :select => 'recording', :conditions => {:mailboxuser => '1000'}).and_return(@vm)
      do_get
    end

    it 'should return the voicemail content' do
      do_get
      last_response.body.should == @vm.recording
    end
  end
end
