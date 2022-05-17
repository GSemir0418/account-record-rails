dir=oh-my-env
# 以时间作为版本 注意空格
time=$(date +"%Y%m%d-%H%M%S")
dist=tmp/mangosteen-$time.tar.gz
current_dir=$(dirname $0)
# 打包的目标路径
deploy_dir=/workspaces/$dir/mangosteen_deploy

# 删除之前存在的
yes | rm tmp/mangosteen-*.tar.gz;
yes | rm $deploy_dir/mangosteen-*.tar.gz;

# 打包 除了tmp/cache中的文件 打包到dist目录 *表示所有不以点开头的文件
tar --exclude="tmp/cache/*" -czv -f $dist *
mkdir -p $deploy_dir
# 将Dockerfile与docker命令文件复制过去
cp $current_dir/../config/host.Dockerfile $deploy_dir/Dockerfile
cp $current_dir/setup_host.sh $deploy_dir/
# 将dist文件（tar包移动出来）
mv $dist $deploy_dir
echo $time > $deploy_dir/version
echo 'DONE'