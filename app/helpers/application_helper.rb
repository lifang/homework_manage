module ApplicationHelper

  def current_user
    @current_user ||= Teacher.find_by_id(session[:user_id]) if session[:user_id]
  end
end
