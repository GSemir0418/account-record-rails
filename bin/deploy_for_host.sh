dir=oh-my-env
# 打包时间作为当前版本号
time=$(date +"%Y%m%d-%H%M%S")
# 打包的目标路径
dist=tmp/mangosteen-$time.tar.gz
current_dir=$(dirname $0)
deploy_dir=/workspaces/$dir/mangosteen_deploy

# 删除之前存在的
yes | rm tem/mangosteen-*.tar.gz;
yes | rm $deploy_dir/mangosteen-*.tar.gz;

# 打包 除了tmp/cache中的文件 打包到dist目录 *表示所有不以点开头的文件
tar --exclude="tmp/cache/*" -czv -f $dist *
mkdir -p $deploy_dir
# 将Dockerfile与docker命令文件复制过去
cp $current_dir/../config/host.Dockerfile $deploy_dir/Dockerfile
cp $current_dir/setup_host.sh $deploy_dir/
mv $dist $deploy_dir
echo $time > $deploy_dir/version
echo $time
echo 'DONE'