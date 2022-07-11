require 'rails_helper'

RSpec.describe "Items", type: :request do
  # 每次测试用例运行完毕，都会自动清空数据表
  describe "获取账目" do
    it "分页，未登录" do
      user1 = User.create email: '1@qq.com'
      11.times { Item.create amount: 99, user_id: user1['id'] }
      get '/api/v1/items'
      expect(response).to have_http_status(401)
    end
    it "登录后，分页获取数据" do
      # 构造用户
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      # 为每个用户构造数据
      11.times { Item.create amount: 99, user_id: user1['id'] }
      11.times { Item.create amount: 99, user_id: user2['id'] }
      expect(Item.count).to eq 22
      # get获取user1的items时要带上权限请求头
      get '/api/v1/items', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 10
      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
    it "按时间筛选" do
      user1 = User.create email: '1@qq.com'
      # 三条数据 两条符合
      item1 = Item.create amount: 100, created_at: '2018-01-02', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2018-01-02', user_id: user1.id
      item3 = Item.create amount: 100, created_at: '2019-01-01', user_id: user1.id
      # 按时间筛选
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-03', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end
    it "按时间筛选(created_at===created_after)" do
      user1 = User.create email: '1@qq.com'
      # 指定时间为标准时区时间
      # item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 1, 0, 0, 0, 'Z')
      # item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 1, 0, 0, 0, '+00:00')
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-03', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "按时间筛选(只传created_after)" do
      user1 = User.create email: '1@qq.com'
      # 指定时间为标准时区时间
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2017-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "按时间筛选(只传created_before)" do
      user1 = User.create email: '1@qq.com'
      # 指定时间为标准时区时间
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2019-01-01', user_id: user1.id
      get '/api/v1/items?created_before=2018-01-03', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
  end
  describe '创建账目' do
    it "未登录创建数据" do
      post '/api/v1/items', params: {amount: 99}
      expect(response).to have_http_status 401
    end
    it '登录创建数据' do
      user = User.create email: '1@qq.com'
      expect {
        post '/api/v1/items', params: {
          amount: 99, 
          tags_id: [1, 2],
          happen_at: '2018-10-01T00:00:00+00:00'
        }, 
        headers: user.generate_auth_header
      }.to change {Item.count}.by(+1)
      expect(response).to have_http_status(201)
      json = JSON.parse response.body
      expect(json['resource']['amount']).to eq(99)
      expect(json['resource']['user_id']).to eq(user.id)
      expect(json['resource']['id']).to be_an(Numeric)
      expect(json['resource']['happen_at']).to eq "2018-10-01T00:00:00.000Z"
    end
    it '创建时amount、happen_at数据必填' do
      user = User.create email: '1@qq.com'
      post '/api/v1/items', params: {}, 
        headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['amount'][0]).to eq "can't be blank"
      expect(json['errors']['happen_at'][0]).to eq "can't be blank"
    end
    it '创建时的tags_id不属于用户' do
      user = User.create email: '1@qq.com'
      tag1 = Tag.create name: 'x', sign: 'x', user_id: user.id
      tag2 = Tag.create name: 'y', sign: 'y', user_id: user.id
      post '/api/v1/items', params: {
          tags_id: [tag1.id,tag2.id, 3],
          amount: 99, 
          happen_at: '2018-10-01T00:00:00+00:00'
        }, 
        headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['tags_id'][0]).to eq "不属于当前用户"
    end
  end
  describe '统计账目' do
    it '按天分组' do
      user = User.create! email: '1@qq.com'
      tag = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      # 只有时间（北京时间+08:00）不同的六条数据
      Item.create! amount: 100, kind: 'expense', tags_id: [tag.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expense', tags_id: [tag.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expense', tags_id: [tag.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expense', tags_id: [tag.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expense', tags_id: [tag.id], happen_at: '2018-06-19T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expense', tags_id: [tag.id], happen_at: '2018-06-19T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
        kind: 'expense',
        group_by: 'happen_at'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happen_at']).to eq '2018-06-18'
      expect(json['groups'][0]['amount']).to eq 300
      expect(json['groups'][1]['happen_at']).to eq '2018-06-19'
      expect(json['groups'][1]['amount']).to eq 300
      expect(json['groups'][2]['happen_at']).to eq '2018-06-20'
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 900
    end
    it '按标签ID分组' do
      user = User.create! email: '1@qq.com'
      tag1 = Tag.create! name: 'tag1', sign: 'x', user_id: user.id
      tag2 = Tag.create! name: 'tag2', sign: 'x', user_id: user.id
      tag3 = Tag.create! name: 'tag3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expense', tags_id: [tag1.id, tag2.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expense', tags_id: [tag2.id, tag3.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expense', tags_id: [tag3.id, tag1.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      # tag3: 500, tag1: 400, tag2: 300
      get '/api/v1/items/summary', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
        kind: 'expense',
        group_by: 'tag_id'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['tag_id']).to eq tag3.id
      expect(json['groups'][0]['amount']).to eq 500
      expect(json['groups'][1]['tag_id']).to eq tag1.id
      expect(json['groups'][1]['amount']).to eq 400
      expect(json['groups'][2]['tag_id']).to eq tag2.id
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 600
    end
  end
end
