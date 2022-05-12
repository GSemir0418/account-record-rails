class Api::V1::ValidationCodesController < ApplicationController
  def create
    validation_code = ValidationCode.new email: params[:email],
      kind: 'log_in', code: SecureRandom.random_number.to_s[2..7]
    if validation_code.save
      head 200
    else 
      render json: {errors: validation_code.errors}
    end
    # TODO:目前仅实现在数据库中创建了validation_code，真正的发送功能待实现
  end
end
