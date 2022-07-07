class Tag < ApplicationRecord
  # 在model层添加限制 让ruby报错而不是数据库报错
  validates :name, presence: true
  validates :sign, presence: true
  belongs_to :user
end
