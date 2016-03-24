class WelcomeController < ApplicationController
  def index
    redirect_to Figaro.env.frontend_host
  end
end
