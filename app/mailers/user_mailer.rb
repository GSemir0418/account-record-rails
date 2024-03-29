class UserMailer < ApplicationMailer
    def welcome_email(email)
        # 先按创建时间排序，以确保code是最新的
        # 再根据传入的email到数据库中查询响应的code
        validation_code = ValidationCode.order(created_at: :desc).find_by_email(email)
        # 给模板传递变量
        @code = validation_code.code
        # 发送邮件
        mail(to: email, subject: '验证码')
    end
end
