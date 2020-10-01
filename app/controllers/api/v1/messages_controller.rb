# frozen_string_literal: true
class Api::V1::MessagesController < Api::V1::ApplicationController
  include TokenAuthenticable
  before_action :set_message, only: [:show, :archive]
  before_action :verify_token, only: [:index, :create, :sent, :archive, :archive_multiple] # validates user token
  before_action :verify_token_or_master, only: :show # validates user token or master permission
  before_action :verify_token_and_master, only: :archived # validates user token and master permission

  def index
    render json: Message.sent_to(@user_token).not_archived.as_json
  end

  def show
    if @message.receiver == @user_token || (is_master_permission? && @user_token.present?)
      render json: @message.as_json
    else
      if @user_token.present?
        head(:unauthorized)
      else
        head(:bad_request)
      end
    end
  end

  def create
    user = User.find_by_email(message_params[:receiver_email])
    @message = Message.new(message_params.merge(from: @user_token&.id, to: user&.id))

    if @message.save
      render json: @message.as_json
    else
      render json: @message.errors, status: 422
    end
  end

  def sent
    render json: Message.sent_from(@user_token).not_archived.as_json
  end

  def archived
    @messages = Message.includes(:sender).archived.ordered
    render json: @messages.as_json
  end

  def archive_multiple
    @messages = Message.find(params[:message_ids])
    @messages.each { |message| message.archived! }
    render json: @messages
  end

  def archive
    @message.archived!
    render json: @message.as_json
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(
        :title,
        :content,
        :receiver_email,
        :to
    )
  end

end