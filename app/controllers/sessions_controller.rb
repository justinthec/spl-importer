class SessionsController < ApplicationController
  def new
  end

  def success
    @auth = request.env['omniauth.auth']['credentials']
  end
end