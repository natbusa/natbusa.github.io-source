hugo
msg=`git log -1 --pretty=%B`
(cd public/ && exec git add . && git commit -am "$msg" && git push)
