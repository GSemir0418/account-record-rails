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
  end
end
