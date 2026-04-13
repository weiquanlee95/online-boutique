#!/bin/bash
# 定义变量
REGISTRY="927749346049.dkr.ecr.ap-southeast-1.amazonaws.com"
TAG="v0.0"

# 定义所有需要构建的服务文件夹
services=("recommendationservice" "cartservice" "shippingservice" "loadgenerator" "shoppingassistantservice" "paymentservice")

for svc in "${services[@]}"; do
  echo "--- 正在处理: $svc ---"
  # 进入对应目录
  cd $svc
  # 跨平台构建并打标
  docker build --platform linux/amd64 -t $REGISTRY/online-boutique/$svc:$TAG .
  # 推送
  docker push $REGISTRY/online-boutique/$svc:$TAG
  cd ..
done
           
                                   
              
                