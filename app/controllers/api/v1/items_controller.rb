class Api::V1::ItemsController < ApplicationController
    def index
        # ruby使用A..B表示范围
        items = Item.where({created_at: params[:created_after]..params[:created_before]}).page params[:page]
        # 也可以Item.page(params[:page]).per(100)自定义pageSize
        render json: { resources: items, pager: {
          page: params[:page],
          per_page: 10,
          count: Item.count
        }}
    end
    
    def create
        item = Item.new amount: params[:amount]
        if item.save
            render json: { resource: item }, status: 201
        else 
            render json: { errors: item.errors }
        end
    end
    
end
