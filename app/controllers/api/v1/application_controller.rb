# frozen_string_literal: true
class Api::V1::ApplicationController < ActionController::API
  # Verifica o token informado para preencher a variável de usuário
  def verify_token
    set_token_user
    unless @user_token.present?
      head(:unauthorized)
    end
  end

  def verify_token_or_master
    set_token_user
    unless @user_token.present? || is_master_permission?
      head(:unauthorized)
    end
  end

  def verify_token_and_master
    set_token_user
    unless @user_token.present? && is_master_permission?
      head(:unauthorized)
    end
  end

  def set_token_user
    @user_token = User.where(token: params[:token]).first
  end

  def is_master_permission?
    params[:permission].to_s == 'master'
  end
end