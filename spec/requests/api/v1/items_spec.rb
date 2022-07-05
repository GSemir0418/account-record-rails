require 'rails_helper'

RSpec.describe "Items", type: :request do
  # 每次测试用例运行完毕，都会自动清空数据表
  describe "GET /items" do
    it "能成功创建并分页返回数据" do
      # 构造用户
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      # 为每个用户构造数据
      11.times { Item.create amount: 99, user_id: user1['id'] }
      11.times { Item.create amount: 99, user_id: user2['id'] }
      expect(Item.count).to eq 22
      # 用户登录，获取user1的jwt
      post '/api/v1/session', params: {
        email: user1.email, code:'123456'
      }
      json = JSON.parse response.body
      jwt = json['jwt']
      # get获取user1的items时要带上权限请求头
      get '/api/v1/items', headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 10
      get '/api/v1/items?page=2', headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
    it "按时间筛选" do
      # 三条数据 两条符合
      item1 = Item.create amount: 100, created_at: '2018-01-02'
      item2 = Item.create amount: 100, created_at: '2018-01-02'
      item3 = Item.create amount: 100, created_at: '2019-01-01'
      # 按时间筛选
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-03'
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end
    it "按时间筛选(created_at===created_after)" do
      # 指定时间为标准时区时间
      # item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 1, 0, 0, 0, 'Z')
      # item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 1, 0, 0, 0, '+00:00')
      item1 = Item.create amount: 100, created_at: '2018-01-01'
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-03'
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "按时间筛选(只传created_after)" do
      # 指定时间为标准时区时间
      item1 = Item.create amount: 100, created_at: '2018-01-01'
      item2 = Item.create amount: 100, created_at: '2017-01-01'
      get '/api/v1/items?created_after=2018-01-01'
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "按时间筛选(只传created_before)" do
      # 指定时间为标准时区时间
      item1 = Item.create amount: 100, created_at: '2018-01-01'
      item2 = Item.create amount: 100, created_at: '2019-01-01'
      get '/api/v1/items?created_before=2018-01-03'
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
  end

  describe 'POST /items' do
    it '能够创建一条数据' do
      # 测试是否在数据表中创建了一条数据 利用change
      expect {
        post '/api/v1/items', params: {amount: 99}
      }.to change {Item.count}.by(+1)
      expect(response).to have_http_status(201)
      json = JSON.parse response.body
      # 测试返回数据的值是否一致
      expect(json['resource']['amount']).to eq(99)
      # 是否有id（只能间接测试）
      expect(json['resource']['id']).to be_an(Numeric)
    end
  end
end
