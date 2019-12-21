GIT_COMMIT_MSG=`git log -1 --pretty=%B`
echo $GIT_COMMIT_MSG
# make clean
# git submodule update --init --recursive
# pushd public
# git checkout master
# popd
make all
pushd public
git add .
git commit -am "$GIT_COMMIT_MSG"
git push
popd
git add public
git commit -am "updated submodule"
git push
