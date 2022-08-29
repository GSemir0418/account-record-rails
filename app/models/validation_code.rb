class ValidationCode < ApplicationRecord
    validates :email, presence: true
    # 定义kind字段的枚举
    enum kind: { sign_in: 0, reset_password: 1 }
    # email需包含@字符
    # \A表示开头 \z表示结尾 .表示任意字符 i表示忽略大小写
    validates :email, format: {with: /\A.+@.+\z/i}

    # 在创建这条记录之前，调用generate_code方法生成随机code
    before_create :generate_code
    # 在save这条记录之后，调用send_email方法发送邮件
    after_create :send_email

    def generate_code
        # self相当于js中的this，指代当前实例对象
        self.code = SecureRandom.random_number.to_s[2..7]
    end
    def send_email
        UserMailer.welcome_email(self.email).deliver
    end
end
