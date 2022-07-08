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
        item = Item.new params.permit(:amount ,:tags_id, :happen_at)
        item.user_id = request.env['current_user_id']
        if item.save
            render json: { resource: item }, status: 201
        else 
            render json: { errors: item.errors }
        end
    end
    
end
