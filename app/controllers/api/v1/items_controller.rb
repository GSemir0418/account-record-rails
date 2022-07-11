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
        hash = Hash.new
        items = Item
          .where(user_id: request.env['current_user_id'])
          .where(kind: params[:kind])
          .where(happen_at: params[:happened_after]..params[:happened_before])
        items.each do |item|
          # 按时间分组，hash的key为happen_at
          if params[:group_by] == 'happen_at' 
            key = item.happen_at.in_time_zone('Beijing').strftime('%F')
            hash[key] ||= 0
            hash[key] += item.amount
          # 按tag_id分组，hash的key为tags_id，此时需要遍历内部的tag_id
          else
            item.tags_id.each do |tag_id|
                hash[tag_id] ||= 0
                hash[tag_id] += item.amount
            end
          end
        end
        groups = hash.map { |key, value| {"#{params[:group_by]}": key, amount: value} }
        # 按时间升序排序
        if params[:group_by] == 'happen_at'
            groups.sort! { |a, b| a[:happen_at] <=> b[:happen_at] }
        # 按tag_id的金额降序排序，注意else if写作elsif
        elsif params[:group_by] == 'tag_id' 
            groups.sort! { |a, b| b[:amount] <=> a[:amount] }
        end
        render json: {
          groups: groups,
          total: items.sum(:amount)
        }
    end
end
