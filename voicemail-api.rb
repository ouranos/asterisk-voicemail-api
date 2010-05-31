require 'rubygems'
require 'sinatra'
require 'lib/sinatra/authorization'
require 'active_record'
require File.expand_path(File.dirname(__FILE__) + '/lib/config')

mime_type :json, "application/json"
mime_type :gsm, "audio/gsm"
mime_type :wav, "audio/wav"

set :authorization_realm, 'Asterisk Voicemail API'

# Models
class Voicemail < ActiveRecord::Base
  set_table_name "voicemessages"
end

class User < ActiveRecord::Base
  set_table_name "vmusers"
end

helpers do
  def authorize(username, password)
    User.count(:conditions => ["mailbox = ? AND password = ?", username, password]) > 0
  end
end

before do
  content_type :json
end

# List voicemails belonging to the current user
get '/voicemails' do
  login_required
  @voicemails = Voicemail.all(:select => "id, dir, context, callerid, origtime, duration", :conditions => {:mailboxuser => auth.username})
  @voicemails.to_json
end

# Send the voicemail content
get '/voicemails/:id' do
  login_required
  content_type :wav
  @voicemail = Voicemail.find(params[:id].to_i, :select => 'recording', :conditions => {:mailboxuser => auth.username})
  @voicemail.recording
end

