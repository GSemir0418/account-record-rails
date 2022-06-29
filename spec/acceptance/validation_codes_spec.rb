require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "验证码" do
  post "/api/v1/validation_codes" do
    # 用于形成文档中的参数表格
    parameter :email, type: :string
    # 用于声明请求参数
    let(:email) { '1@qq.com' }
    example "请求发送验证码" do
      # 测试是否调用了UserMailer中的welcome_email方法
      expect(UserMailer).to receive(:welcome_email).with(email)
      do_request
      expect(status).to eq 200
      expect(response_body).to eq ' '
    end
  end
end