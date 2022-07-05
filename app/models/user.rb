class User < ApplicationRecord
    validates :email, presence: true
    def generate_jwt
        hmac_secret = Rails.application.credentials.hmac_secret
        # self相当于this
        payload = { user_id: self.id }
        # ruby会自动返回最后一句
        JWT.encode payload, hmac_secret, 'HS256'
    end
    def generate_auth_header
        {"Authorization": "Bearer #{self.generate_jwt}"}
    end
end
