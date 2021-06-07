# NLP 스터디를 위한 Dockerfile
- base는 한국어 임베딩 리포지토리의 Dockerfile을 따름
- 추가적으로 사용에 필요한 몇몇 라이브러리를 추가함

# Dockerfile 사용법
1. docker가 설치되어 있어야함
2. pull 받은 dockerfile에 추가적으로 필요한 부분을 업데이트 한 후 사용
3. dockerfile을 이용해서 이미지를 build한 후 사용

# 실행 Command
```bash
# build image
docker build -t [tag 이름] -f [dockerfile 위치]
# ex) docker build -t nlp/iron -f Dockerfile .

# run docker
docker run -it --rm [tag 이름] bash
# ex) docker run -it --rm iron/nlp bash

# manage docker
# check docker list
docker ps -a

# delete docker container
docker rm $(docker ps -a -q) #전체 삭제
docker rm [container id]