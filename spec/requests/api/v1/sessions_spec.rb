require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "会话" do
    it "登录（创建）会话" do
      # 在数据库中创建一个假用户
      User.create email:'845217811@qq.com'
      # code临时规定为'123456'
      post '/api/v1/session', params: {
        email: '845217811@qq.com', code:'123456'
      }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      # 期待测试通过，且响应体存在JWT字符串
      expect(json['jwt']).to be_a(String)
    end
    it "首次登录" do
      # 直接登录 期待自动创建用户
      post '/api/v1/session', params: {
        email: '845217811@qq.com', code:'123456'
      }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      # 期待测试通过，且响应体存在JWT字符串
      expect(json['jwt']).to be_a(String)
    end
  end
end
