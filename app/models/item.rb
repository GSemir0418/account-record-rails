class Item < ApplicationRecord
    enum kind: {expense: 1, income: 2}
    validates :amount, presence: true
    validates :kind, presence: true
    validates :happen_at, presence: true
    validates :tags_id, presence: true
end
