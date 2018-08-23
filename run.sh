#!/bin/bash

for ((i=$1; i < $2; i++))
do
   bundle exec ruby run.rb $i $2 &
done
