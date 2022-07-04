require 'rails_helper'

RSpec.describe "Me", type: :request do
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
  end
end

