require 'rails_helper'

RSpec.describe "Items", type: :request do
  # 每次测试用例运行完毕，都会自动清空数据表
  describe "GET /items" do
    it "能成功创建并分页返回数据" do
      # 创建11条数据
      11.times { Item.create amount: 99 }
      # 此时期待数据库中有11条数据，表示创建成功
      expect(Item.count).to eq 11

      # 接下来构造请求
      get '/api/v1/items'
      # 期待状态码为200 即请求成功
      expect(response).to have_http_status(200)
      # 将返回数据反序列化
      json = JSON.parse response.body
      # 期待返回的数据条数为10(因为默认pageSize为10)，看是否成功返回
      expect(json['resources'].size).to eq 10

      # 同理测试分页接口
      get '/api/v1/items?page=2'
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
    it "按时间筛选" do
      # 三条数据 两条符合
      item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 2)
      item2 = Item.create amount: 100, created_at: Time.new(2018, 1, 2)
      item3 = Item.create amount: 100, created_at: Time.new(2019, 1, 2)
      # 按时间筛选
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-03'
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
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
