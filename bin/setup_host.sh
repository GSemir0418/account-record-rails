container_name=mangosteen-prod-1
version=$(cat mangosteen_deploy/version)

echo 'docker build ...'
docker build mangosteen_deploy -t mangosteen:$version
if [ "$(docker ps -aq -f name=^mangosteen-prod-1$)" ]; then
  echo 'docker rm ...'
  docker rm -f $container_name
fi
echo 'docker run ...'
docker run -d -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY -p 3000:3000 --network=network1 -e DB_HOST=$DB_HOST -e DB_PASSWORD=$DB_PASSWORD --name=$container_name mangosteen:$version
# echo 'docker exec ...'
# 创建数据库 同步数据表
# docker exec -it $container_name bin/rails db:create db:migrate
echo 'DONE'