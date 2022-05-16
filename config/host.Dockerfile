# 基于ruby3.0.0构建ruby运行环境的容器
FROM ruby:3.0.0

# 设置rails环境变量为production
ENV RAILS_ENV production
RUN mkdir /mangosteen
# 配置bundle源
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /mangosteen
# 将源代码放入当前工作目录中（ADD会自动解压缩tar包）
ADD mangosteen-*.tar.gz ./
# 安装依赖（先配置 安装时排除开发和测试环境的依赖）
RUN bundle config set --local without 'development test'
RUN bundle install
# bundle exec rails server 是专门用在开发环境的
# 生产环境用puma
# 只在docker run时执行，build时不执行
ENTRYPOINT bundle exec puma