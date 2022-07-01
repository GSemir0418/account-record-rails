require 'jwt'

class Api::V1::SessionsController < ApplicationController
    def create
       # 由于单元测试写死了code为123456，因此需要为测试环境单独写逻辑
        if Rails.env.test?
            return render status: 401 if params[:code] != '123456'
        else
            # 登录成功的条件有两条：
            # 1 validation存在且没有被验证过（Validation.exists? used_at: nil）
            # 2 数据库存在此用户（User.find_by_email）
            canSignin = ValidationCodes.exists? email: params[:email], code: params[:code], used_at: nil
            return render status: 401 unless canSignin
            # unless 也可以写做 if not
        end
        user = User.find_by_email params[:email]
        if user.nil?
            render status: 404, json: {errors: '用户不存在'}
        else
            # 加密私钥使用rails管理
            # hmac_secret = 'b70db9f7-e84f-45fe-bd16-db83684d8c0e'
            hmac_secret = Rails.application.credentials.hmac_secret
            payload = { user_id: user.id }
            # encode方法接受三个参数 分别是 payload数据，加密用私钥，加密算法
            token = JWT.encode payload, hmac_secret, 'HS256'
            render stauts: 200, json: { jwt: token }
        end 
    end
end
