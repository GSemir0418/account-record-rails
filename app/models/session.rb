class Session
    include ActiveModel::Model
    # Rails会默认读取ActiveRecord的表与字段
    # 由于数据库不存在Session的model，只能手动指定字段与其访问器（get set）
    attr_accessor :email, :code
    # 默认的必填与格式校验
    validates :email, :code, presence: true
    validates :email, format: {with: /\A.+@.+\z/i}
    # 自定义校验
    validate :check_validation_code
    def check_validation_code
        # 区分生产与开发环境
        return if Rails.env.test? and self.code == '123456'
        # 前面做了presence的校验，由于校验是依次执行的，所以即使code为空这里也会被执行
        return if self.code.empty?
        # 如果code不存在 则报错code 404
        self.errors.add :email, :not_found unless
            ValidationCode.exists? email: self.email, code: self.code, used_at: nil
    end
end