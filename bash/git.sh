#!/bin/bash
module load git
#http://blog.csdn.net/sinat_20177327/article/details/76062030
#http://kbroman.org/github_tutorial/pages/init.html

operation=$1
folder="../README.md ../backup/* ../bash/*sh ../figures/* ../gmt/*cpt ../gmt/*sh ../octave/*m ../slurm/*sh ../backup/Par_file.part"

#folder=$2

if [ $operation == 'push' ]
then
git add $folder
git commit -m "pushing to Github"
git push origin master
elif [ $operation == 'pull' ]
then
git commit -m "pulling from Github"
git pull origin master
fi

module unload git
cd -
