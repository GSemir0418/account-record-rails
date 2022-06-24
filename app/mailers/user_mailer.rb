class UserMailer < ApplicationMailer
    def welcome_email(code)
        # 给模板传递变量
        @code = code
        mail(to: "845217811@qq.com", subject: 'Welcome to My Awesome Site')
    end
end
