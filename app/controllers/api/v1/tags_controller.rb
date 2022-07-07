class Api::V1::TagsController < ApplicationController
    def index
        current_user = User.find request.env['current_user_id']
        return render status: 401 if current_user.nil?
        tags = Tag.where({user_id: current_user.id}).page(params[:page])
        render json: {resources: tags, pager: {
            page: params[:page] || 1,
            per_page: Tag.default_per_page,
            count: Tag.count
            }}
    end
    def show
        current_user = User.find request.env['current_user_id']
        return render status: 401 if current_user.nil?
        tag = Tag.find params[:id]
        return render status: 403 unless current_user.id == tag.user_id 
        render json: {resource: tag}
    end
    def create
        current_user = User.find request.env['current_user_id']
        return render status: 401 if current_user.nil?
        # new表示仅创建tag实例，create表示在new + save
        tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user.id
        # save会返回true/false 而create则会直接报错
        if tag.save
            render json:{resource: tag}
        else
            render json:{errors: tag.errors}, status: :unprocessable_entity
        end
    end
    def update
        tag = Tag.find params[:id]
        # permit表示仅接收传入的字段的非空值
        # update尝试更新数据库字段 如果出错会返回tag.errors
        tag.update params.permit(:name, :sign)
        # nil仅判空 empty还会判断size
        if tag.errors.empty?
            render json: {resource: tag}
        else
            render json: {errors: tag.errors}, status: :unprocessable_entity
        end 
    end
    def destroy 
        tag = Tag.find params[:id]
        # 没有删除别人的标签的权限
        return head 403 unless tag.user_id == request.env['current_user_id']
        # 软删除 更新deleted_at字段即可
        tag.delete_at = Time.now
        if tag.save
            head 200
        else
            render json: {errors: tag.errors}, status: :unprocessable_entity
        end
    end
end
