class AutoJwt
    # 包括两个方法，initialize和call
    def initialize(app)
        @app = app
    end
    # 中间件被调用时需要执行的方法
    # 参数的env包括请求与响应的所有信息
    def call(env)
        # jwt跳过以下路径
        return @app.call(env) if ['/api/v1/session', '/api/v1/validation_codes'].include?(env['PATH_INFO'])
        # 获取header中的jwt
        header = env['HTTP_AUTHORIZATION']
        jwt = header.split(' ')[1] rescue ''
        # payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' } rescue nil
        # JWT.decode方法会自动进行过期时间检查
        # 改写为更全面的rescue，区别过期报错与其他报错
        begin
            payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' }
        rescue JWT::ExpiredSignature
            return [401, {}, [JSON.generate({reason: 'jwt expired'})]]
        rescue
            return [401, {}, [JSON.generate({reason: 'jwt invalid'})]]
        end
        # 将解析出来的user_id写入env中
        env['current_user_id'] = payload[0]['user_id'] rescue nil
        # 继续执行controller，如果不写这句，controller的逻辑就自动跳过了
        # @status, @headers, @response就是controller返回的响应数据
        @status, @headers, @response = @app.call(env) 
        [@status, @headers, @response]
        # call方法必须返回状态码、响应头、响应体
        # [200, {}, ['Hello World', 'Hi']]
    end
end