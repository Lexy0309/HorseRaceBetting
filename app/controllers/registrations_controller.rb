class RegistrationsController < Devise::RegistrationsController

  respond_to :html, :js
  
  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :state_manual, :terms_confirmed, :email, :password, :password_confirmation, :current_password,bookmaker_ids:[])
  end
end
