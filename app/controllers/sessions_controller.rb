class SessionsController < Devise::SessionsController

  respond_to :html, :js

  def new
    respond_to do |format|
      format.html { redirect_to login_index_path }
      format.js
    end
  end

end
