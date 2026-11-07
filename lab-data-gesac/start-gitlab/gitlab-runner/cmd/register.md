# GitLab Runner 服务端程序

镜像：gitlab/gitlab-runner:19.6.0-pre.2431.g7f6cf1f5

作用：负责接收和调度 Job

## 在服务内执行
gitlab-runner register \
--url http://gitlab:8929 \
--token glrt-J42bWuMeBMGGNUCFpC-yL2c6NApvOjEKdDoyCnU6Mw8.01.170i0ti2u

Enter an executor 填 docker
Enter the default Docker image 填 ubuntu:22.04



