class Api::V1::ItemsController < ApplicationController
    def index
        items = Item.page params[:page]
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
