require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "验证码" do
    it "60秒内不能重复发送" do
      post '/api/v1/validation_codes', params: {
        email: '845217811@qq.com'
      }
      expect(response).to have_http_status(200)
      post '/api/v1/validation_codes', params: {
        email: '845217811@qq.com'
      }
      expect(response).to have_http_status(429)
    end
    it "email格式不合法会报422" do
      post '/api/v1/validation_codes', params: {
        email: '123'
      }
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['email'][0]).to eq('邮件地址格式不正确')
    end
  end
end
