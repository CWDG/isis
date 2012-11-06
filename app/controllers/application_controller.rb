class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_agent

  private

  def current_agent
    @current_agent ||= Agent.find(session[:agent_id]) if session[:agent_id]
  end


end
