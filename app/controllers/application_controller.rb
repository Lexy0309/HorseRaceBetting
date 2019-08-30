class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :redirect_subdomain

  include ApplicationHelper
  def access_deny_in_if_not_a_user
    #redirect_to home_index_path unless user_signed_in?
    redirect_to new_user_session_path unless user_signed_in?
  end

  def access_deny_in_if_not_an_admin
    if !user_signed_in? || !current_user.is_admin
      #redirect_to home_index_path
      redirect_to new_user_session_path
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    #home_index_path
    new_user_session_path
  end

  def force_user_to_fill_in_info
    if current_user.first_name.blank? || current_user.last_name.blank? || current_user.state_manual.blank? || !current_user.terms_confirmed
      #flash[:notice] = 'You need to fill in all fields to continue.'
      redirect_to edit_user_registration_path
    end
  end

  def redirect_subdomain
    if Rails.env.production? && request.subdomain.start_with?('www')
      redirect_to 'https://' + request.subdomain.gsub('www.','') + '.' + request.domain + request.fullpath, :status => 301
    end
  end

end
