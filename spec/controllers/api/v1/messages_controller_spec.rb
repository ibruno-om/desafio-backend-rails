# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:user1) { FactoryBot.create(:user) }
  let(:master) { FactoryBot.create(:user, :master) }
  let(:message) { FactoryBot.create(:message, to: user.id, from: user1.id) }
  let(:message1) { FactoryBot.create(:message, to: user.id, from: user1.id) }

  describe 'GET messages#index' do
    it 'unauthorized' do
      get :index
      expect(response).to have_http_status(401)
    end

    it 'authorized' do
      message
      get :index, params: { token: user.token }
      expect(response.body).to eq([message].to_json)
    end

    it 'empty messages' do
      message
      get :index, params: { token: user1.token }
      expect(response.body).to eq([].to_json)
    end
  end

  describe 'GET messages#show' do
    it 'unauthorized' do
      get :show, params: {id: message.id}
      expect(response).to have_http_status(401)
    end

    it 'another user unauthorized' do
      message
      get :show, params: {token: user1.token, id: message.id}
      expect(response).to have_http_status(401)
    end

    it 'authorized' do
      message
      get :show, params: {token: user.token, id: message.id}
      expect(response.body).to eq(message.to_json)
    end

    it 'master' do
      message
      get :show, params: {token: master.token, id: message.id, permission: 'master'}
      expect(response.body).to eq(message.to_json)
    end
  end

  describe 'POST messages#create' do
    it 'unauthorized' do
      post :create, params: {message: create_success }
      expect(response).to have_http_status(401)
    end

    it 'success' do
      post :create, params: {token: user.token, message: create_success}
      expect(response).to have_http_status(200)
    end

    it 'error' do
      post :create, params: {token: user.token, message: create_error}
      expect(response).to have_http_status(422)
    end

  end

  describe 'GET messages#sent' do
    it 'unauthorized' do
      get :sent
      expect(response).to have_http_status(401)
    end

    it 'return sent messages' do
      message
      get :sent, params: {token: user1.token}
      expect(response.body).to eq([message].to_json)
    end

    it 'empty messages' do
      message
      get :sent, params: {token: user.token}
      expect(response.body).to eq([].to_json)
    end
  end

  describe "GET messages#archived" do
    it 'unauthorized' do
      get :archived
      expect(response).to have_http_status(401)
    end

    it 'not a master user unauthorized' do
      get :archived, params: {token: user.token}
      expect(response).to have_http_status(401)
    end

    it 'master authorized archived messages' do
      message.archived!
      get :archived, params: {token: master.token, permission: 'master'}
      expect(response.body).to eq([message].to_json)
    end

  end

  describe 'PATCH message#archive' do
    it 'unauthorized' do
      message
      patch :archive, params: {id: message.id}
      expect(response).to have_http_status(401)
    end

    it 'archive message' do
      message
      patch :archive, params: {id: message.id, token: user.token, permission: 'master'}
      expect(response).to have_http_status(200)
    end

  end

  describe 'GET messages#archive_multiple' do
    it 'unauthorized' do
      patch :archive_multiple, params: {message_ids: [message.id, message1.id] }
      expect(response).to have_http_status(401)
    end


    it 'archive multiples messages' do
      patch :archive_multiple, params: {message_ids: [message.id, message1.id], token: master.token, permission: 'master'}
      expect(response).to have_http_status(200)
    end
  end

  def create_success
    {title: 'Mensagem', content: 'Conteudo da mensagem', receiver_email: user1.email}
  end

  def create_error
    {title: 'Mensagem', content: 'Conteudo da mensagem'}
  end


end