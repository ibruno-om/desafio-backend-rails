# frozen_string_literal: true
class Api::V1::UsersController < Api::V1::ApplicationController
  include TokenAuthenticable

  before_action :verify_token_and_master, only: [:index, :messages]
  before_action :set_user, only: [:messages, :update]

  def index
    render json: User.all.as_json
  end

  def messages
    if @user.present?
      @sent = Message.sent_from(@user).ordered
      @received = Message.sent_to(@user).ordered
      render json: { sent: @sent, received: @received}.as_json
    else
      head(:bad_request)
    end
  end

  def update
    if user_params[:password].blank? || user_params[:password_confirmation].blank? # remove password if both fields are not filled
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user == @user_token # check if the token user is the same on update

      if @user.update(user_params)
        render json: @user.as_json
      else
        render json: @user.errors, status: 422
      end

    else
      head(:unauthorized)
    end
  end

  private

  def set_user
    @user = User.find(params[:id] || params[:user_id])
  end

  def user_params
    params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation
    )
  end
end