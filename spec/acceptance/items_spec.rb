require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
    get "/api/v1/items" do
        # 描述请求 parameter
        parameter :page, '页码'
        parameter :created_after, '创建时间起点（筛选条件）'
        parameter :created_before, '创建时间终点（筛选条件）'

        # 描述响应 response_field
        # response_field :id, 'ID', scope: :resources
        # response_field :amount, '金额（单位：分）', scope: :resources
        # 以上两句有相同的scope，所以可以简写为下面的
        with_options :scope => :resources do
            response_field :id, 'ID'
            response_field :amount, '金额（单位：分）'
        end

        # 构造示例请求
        let(:created_after) {'2021-01-01'}
        let(:created_before) {'2022-01-01'}
        example "获取账目" do
            11.times do Item.create amount: 100, created_at: '2021-6-30' end
            do_request
            expect(status).to eq 200
            json = JSON.parse response_body
            expect(json['resources'].size).to eq 10
        end
    end
end

