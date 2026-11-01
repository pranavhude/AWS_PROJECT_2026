# AWSPro ECS Test Application

A minimal Node.js HTTP application for testing an Amazon ECS cluster using the EC2 launch type.

## Container details

- Listens on `0.0.0.0:80`
- `GET /` returns a test webpage
- `GET /health` returns HTTP 200 with `{"status":"healthy"}`
- Handles `SIGTERM` for graceful shutdown

## Build locally

```bash
docker build -t awspro-ecs-test-app:1.0 .
docker run --rm -p 8080:80 awspro-ecs-test-app:1.0
```

Open `http://localhost:8080` and test `http://localhost:8080/health`.

## Push to Amazon ECR

Replace `<AWS_ACCOUNT_ID>` and `<AWS_REGION>` with your values. For this project, the region is `ap-south-1`. Create the ECR repository named `awspro-ecs-test-app` first.

```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

docker build -t awspro-ecs-test-app:1.0 .

docker tag awspro-ecs-test-app:1.0 <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/awspro-ecs-test-app:1.0

docker push <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/awspro-ecs-test-app:1.0
```

## ECS Task Definition guidance

For a first single-task test on ECS EC2:

- Launch type / capacity provider: EC2 capacity provider
- Network mode: `bridge`
- Container name: `awspro-ecs-test-app`
- Container image: the ECR image URI created above
- Container port: `80`
- Host port: `80` for a single task per EC2 instance

If you want multiple tasks per EC2 instance, use dynamic host port mapping (`hostPort: 0`) and configure the ALB target group for `instance` targets with the ECS service registering the dynamic host ports.

Configure the ALB health check path as `/health`. Ensure the ALB security group can reach the EC2 security group on the selected host port(s).
