# 服务器的user和ip
user=mangosteen
ip=47.111.31.50

time=$(date +'%Y%m%d-%H%M%S')
dist=tmp/mangosteen-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=/home/$user/deploys/$time
vendor_cache_dir=$current_dir/../vendor/cache
gemfile=$current_dir/../Gemfile
gemfile_lock=$current_dir/../Gemfile.lock

function title {
  echo 
  echo "###############################################################################"
  echo "## $1"
  echo "###############################################################################" 
  echo 
}

yes | rm tmp/mangosteen-*.tar.gz

title '打包源代码为压缩文件'
bundle cache
tar --exclude="tmp/cache/*" -czv -f $dist *
title '创建远程目录'
ssh $user@$ip "mkdir -p $deploy_dir"
# 创建deploy_dir以及vendor目录
ssh $user@$ip "mkdir -p $deploy_dir/vendor"
title '上传压缩文件'
# scp = ssh copy
scp $dist $user@$ip:$deploy_dir/
scp $gemfile $user@$ip:$deploy_dir/
scp $gemfile_lock $user@$ip:$deploy_dir/
# 将cache也上传到部署目录下 -r表示整个路径下的内容
scp -r $vendor_cache_dir $user@$ip:$deploy_dir/vendor/
title '上传 Dockerfile'
scp $current_dir/../config/host.Dockerfile $user@$ip:$deploy_dir/Dockerfile
title '上传 setup 脚本'
scp $current_dir/setup_remote.sh $user@$ip:$deploy_dir/
title '上传版本号'
ssh $user@$ip "echo $time > $deploy_dir/version"
title '执行远程脚本'
ssh $user@$ip "export version=$time; /bin/bash $deploy_dir/setup_remote.sh"
