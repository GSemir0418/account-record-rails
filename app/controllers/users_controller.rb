class UsersController < ApplicationController
  def show
    p '你访问了show'
  end

  def create
    u1 = User.new name: 'gsq'
    if u1.save
      render json:u1
    else
      render json:u1.errors
    end
  end
end
