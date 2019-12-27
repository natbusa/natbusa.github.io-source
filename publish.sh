GIT_COMMIT_MSG=`git log -1 --pretty=%B`
echo "Last git message: $GIT_COMMIT_MSG"
make clean
make
pushd public
git add .
git commit -am "$GIT_COMMIT_MSG"
git push
popd
git add public
git commit -am "updated submodule"
git push
