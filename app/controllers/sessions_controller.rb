class SessionsController < ApplicationController
  def new
  end

  def create
    @auth = request.env['omniauth.auth']['credentials']
  end
end