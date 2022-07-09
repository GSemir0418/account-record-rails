class Item < ApplicationRecord
    enum kind: {expense: 1, income: 2}
    validates :amount, presence: true
    validates :kind, presence: true
    validates :happen_at, presence: true
    # validates :tags_id, presence: true
    # 有s的是默认校验，传值即可
    # 没有s的是自定义校验，指定校验方法
    validate :check_tags_id_belong_to_user

    def check_tags_id_belong_to_user
        # 遍历当前用户的全部tags
        all_tag_ids = Tag.where(user_id: self.user_id).map{|tag| tag.id}
        # 如果传入的tags_id如果与all_tag_ids不存在交集
        # ruby中的==对比两个数组时，会遍历全部内部元素进行比较
        if self.tags_id & all_tag_ids != self.tags_id
            # 说明不是当前用户的tags，报错
            self.errors.add :tags_id, "不属于当前用户"
        end
    end
end
