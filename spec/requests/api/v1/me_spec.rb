require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Me", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "获取当前登录用户" do
    it "登录后成功获取" do
      user = User.create email:'845217811@qq.com'
      # 先登录
      post '/api/v1/session', params: {
        email: '845217811@qq.com', code:'123456'
      }
      json = JSON.parse response.body
      jwt = json['jwt']
      # 再获取当前登录用户，记得设置请求头
      get '/api/v1/me', headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      # 期待返回的用户id与我们创建的用户id一致
      expect(json['resource']['id']).to eq user.id
    end
    it "jwt过期" do
      # 先把时间倒回到三小时前，创建jwt
      travel_to Time.now - 3.hours
      user = User.create email:'845217811@qq.com'
      jwt = user.generate_jwt
      # 回到现在
      travel_back
      get '/api/v1/me', headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(401)
    end
  end
end

