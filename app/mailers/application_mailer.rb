class ApplicationMailer < ActionMailer::Base
  # 全局发送邮件地址
  default from: "845217811@qq.com"
  # html默认布局
  layout 'mailer'
end
