class Api::V1::ItemsController < ApplicationController
    def index
        # 获取前鉴权，获取登录用户id
        current_user_id = request.env['current_user_id']
        return head 401 if current_user_id.nil?
        # ruby使用A..B表示范围
        items = Item.where({user_id: current_user_id})
            .where({created_at: params[:created_after]..params[:created_before]})
            .page params[:page]
        # 也可以Item.page(params[:page]).per(100)自定义pageSize
        render json: { resources: items, pager: {
          page: params[:page] || 1,
          per_page: Item.default_per_page,
          count: Item.count
        }}
    end
    
    def create
        # item = Item.new amount: params[:amount], tags_id: params[:tags_id],
            # happen_at: params['happen_at']
        # 可简写为 
        item = Item.new params.permit(:amount, :happen_at ,tags_id:[])
        item.user_id = request.env['current_user_id']
        if item.save
            render json: { resource: item }, status: 201
        else 
            render json: { errors: item.errors }, status: 422
        end
    end

    def summary
        # 最后的hash be like {2018-06-18:300,2018-06-19:300,2018-06-20:300,}
        hash = Hash.new
        # 1.拿到该用户在时间范围内全部的支出/收入的items
        items = Item
          .where(user_id: request.env['current_user_id'])
          .where(kind: params[:kind])
          .where(happen_at: params[:happened_after]..params[:happened_before])
        # 2.遍历items，借助hash累加每天的amount
        items.each do |item|
          # 规范格式（%F相当于%Y-%m-%d的简写）
          key = item.happen_at.in_time_zone('Beijing').strftime('%F')
          # 如果hash[key]没有值，则初始化为零，相当于hash[key] = hash[key] || 0
          hash[key] ||= 0
          # 加上当前金额
          hash[key] += item.amount
        end
        # 3.将hash遍历为数组（map），并排序
        groups = hash
          .map { |key, value| {"happen_at": key, amount: value} }
          # <=> spaceship operator 返回-1 0 1
          # sort!表示改变当前数组，不创建新数组
          .sort { |a, b| a[:happen_at] <=> b[:happen_at] }
        render json: {
          groups: groups,
          # 求和利用items.sum(求和的字段)
          total: items.sum(:amount)
        }
      end
    
end
