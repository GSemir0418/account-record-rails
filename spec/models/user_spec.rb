# 一些辅助功能可以写在这里，例如登录功能
require 'rails_helper'

RSpec.describe User, type: :model do
  it '有email' do
    user = User.new email: 'gsq@zs.com'
    # to eq 相当于对比值是否相等
    # to be 相当于对比两个对象，当然也包括对象的地址
    expect(user.email).to eq 'gsq@zs.com'
  end
end
