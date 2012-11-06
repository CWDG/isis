class SessionsController < ApplicationController
  def new
  end

  def create
    agent = Agent.authenticate(params[:code_name], params[:password])
    if agent
      session[:agent_id] = agent.id
      redirect_to root_url, notice: "Access Granted. Welcome Agent #{agent.code_name}"
    else
      flash.now.alert = "Access Denied! Unable to verify your identity."
      render :new
    end
  end

  def destroy
    if session[:agent_id]
      session[:agent_id] = nil
      redirect_to root_url, notice: "Logged out. Don't get captured."
    else
      redirect_to root_url
    end
  end



end
