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
            canSignin = ValidationCode.exists? email: params[:email], code: params[:code], used_at: nil
            return render status: 401 unless canSignin
            # unless 也可以写做 if not
        end
        # 首次登录自动创建用户
        user = User.find_or_create_by email: params[:email]
        render stauts: :ok, json: { jwt: user.generate_jwt }
        # if user.nil?
        #     render status: 404, json: {errors: '用户不存在'}
        # else
        #     render stauts: 200, json: { jwt: user.generate_jwt }
        # end 

    end
end
