require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:user1) { FactoryBot.create(:user) }
  let(:master) { FactoryBot.create(:user, :master) }
  let(:message) { FactoryBot.create(:message, to: user.id, from: user1.id) }
  let(:message1) { FactoryBot.create(:message, to: user.id, from: user1.id) }

  describe 'GET users#index' do

    it 'unauthorized' do
      get :index
      expect(response).to have_http_status(401)
    end

    it 'not master user unauthorized' do
      get :index, params: {token: user.token}
      expect(response).to have_http_status(401)
    end

    it 'master user authorized' do
      get :index, params: {token: master.token, permission: 'master'}
      expect(response.body).to eq(User.all.to_json)
    end

  end

  describe 'GET users#messages' do
    it 'unauthorized' do
      get :messages, params: {user_id: user.id}
      expect(response).to have_http_status(401)
    end

    it 'not user master unauthorized' do
      get :messages, params: {token: user.token, user_id: user.id}
      expect(response).to have_http_status(401)
    end

    it 'not user master unauthorized' do
      get :messages, params: {token: master.token, user_id: user.id, permission: 'master'}
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH users#update' do
    it 'unauthorized' do
      patch :update, params: {id: user.id, user: update_user}
      expect(response).to have_http_status(401)
    end

    it 'other user token unauthorized' do
      patch :update, params: {id: user.id, user: update_user, token: user1.token}
      expect(response).to have_http_status(401)
    end

    it 'success update user' do
      patch :update, params: {id: user.id, user: update_user, token: user.token}
      user.update(update_user)
      expect(response).to have_http_status(200)
    end

  end

  def update_user
    {name: 'Editado',email: 'editado@email.com'}
  end
end