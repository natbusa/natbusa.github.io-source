hugo
msg=`git log -1 --pretty=%B`
pushd public
git add .
git commit -am "$msg"
git push
popd
