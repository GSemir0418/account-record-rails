class Api::V1::ValidationCodesController < ApplicationController
  def create
    # 重复请求验证码的校验
    if ValidationCode.exists?(email: params[:email], kind: 'sign_in', created_at: 1.minute.ago..Time.now)
      render status: 429
      return 
    end
    validation_code = ValidationCode.new email: params[:email], kind: 'sign_in'
      if validation_code.save
        render status: 200
      else
        render json: { errors: validation_code.errors }, status: 400
      end
  end
end
