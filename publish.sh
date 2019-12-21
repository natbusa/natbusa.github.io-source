GIT_COMMIT_MSG=`git log -1 --pretty=%B`
rm -rf public
git submodule update --init --recursive
pushd public
git checkout master
popd
hugo
pushd public
git add .
git commit -am "$GIT_COMMIT_MSG"
git push
popd
git add public
git commit -am "updated submodule"
git push
