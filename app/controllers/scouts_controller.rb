class ScoutsController < ApplicationController
  before_action :authenticate_user_and_company

  def index
    if company_signed_in?
      @scouts = current_company.scouts
    elsif user_signed_in?
      @scouts = current_user.scouts
    end
  end

  def create
    scout = current_company.scouts.create(scout_params)
    Notification.create(
      target_model: "user",
      target_model_id: scout.user_id,
      action_model: "scout",
      action_model_id: scout.id)
    redirect_to user_path(scout.user_id), notice: "#{scout.user.first_name}さんをスカウトしました"
  end

  def destroy
    scout = current_company.scouts.find_by(user_id: params[:user_id]).destroy
    redirect_to user_path(params[:user_id]), notice: "#{scout.user.first_name}さんのスカウトを解除しました。"
  end

  private

  def scout_params
    params.require(:scout).permit(:user_id, :company_id)
  end
end
