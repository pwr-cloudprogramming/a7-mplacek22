# Maja Placek - Terraform, EC2, TicTacToe report

- Course: Cloud programming
- Group: monday 9:15
- Date: 

## Environment architecture

## Elastic Beanstalk

### Provider Configuration
- **AWS Provider**: Region set to `us-east-1`.

### Networking Components
- **VPC**: `app_vpc` (CIDR: `10.0.0.0/16`)
  - **Internet Gateway**: `app_gw`
  - **Subnets**:
    - `backend_subnet` (CIDR: `10.0.1.0/24`, AZ: `us-east-1a`)
    - `frontend_subnet` (CIDR: `10.0.2.0/24`, AZ: `us-east-1b`)
  - **Route Table**: `app_rt`
    - Routes all traffic (`0.0.0.0/0`) to the internet gateway.
    - Associated with both subnets.

### Security Groups
- **Backend SG**: `backend_sg`
  - Inbound: TCP on port `8080` (from `0.0.0.0/0`)
  - Outbound: All traffic
- **Frontend SG**: `frontend_sg`
  - Inbound: TCP on port `3000` (from `0.0.0.0/0`)
  - Outbound: All traffic

### Elastic Beanstalk Applications and Environments
- **Applications**:
  - `backend_app`
  - `frontend_app_v2`
- **Environments**:
  - `backend-env-1`
    - Application: `backend_app`
    - Version: `backend_version`
    - Configured for VPC, subnet, public IP, service role, architecture, instance type, security group.
  - `frontend-env-1`
    - Application: `frontend_app_v2`
    - Version: `frontend_version`
    - Configured for VPC, subnet, public IP, service role, architecture, instance type, security group.

### S3 Buckets and Objects
- **Bucket**: `appbuckettictactoe`
  - **Objects**:
    - `backend_deploy.zip`
    - `frontend_deploy.zip`

### Outputs
- **Backend URL**: `http://${aws_elastic_beanstalk_environment.backend_env.cname}:8080`
- **Frontend URL**: `http://${aws_elastic_beanstalk_environment.frontend_env.cname}:3000`

## Fargate

### Provider Configuration
- **AWS Provider**: Region set to `us-east-1`.

### Networking Components
- **VPC**: `tictactoe_vpc` (CIDR: `10.0.0.0/16`)
  - **Internet Gateway**: `tictactoe_gateway`
  - **Subnets**:
    - `tictactoe_subnet1` (CIDR: `10.0.1.0/24`, AZ: `us-east-1a`)
    - `tictactoe_subnet2` (CIDR: `10.0.2.0/24`, AZ: `us-east-1b`)
  - **Route Table**: `tictactoe_route_table`
    - Routes all traffic (`0.0.0.0/0`) to the internet gateway.
    - Associated with both subnets.

### Security Groups
- **Backend SG**: `backend_sg`
  - Inbound: TCP on ports `8080` and `22` (from `0.0.0.0/0`)
  - Outbound: All traffic
- **Frontend SG**: `frontend_sg`
  - Inbound: TCP on ports `3000` and `22` (from `0.0.0.0/0`)
  - Outbound: All traffic
- **ALB SG**: `alb_sg`
  - Inbound: TCP on ports `3000`, `8080`, and `22` (from `0.0.0.0/0`)
  - Outbound: All traffic

### Load Balancer
- **ALB**: `tictactoe-alb`
  - Subnets: `tictactoe_subnet1` and `tictactoe_subnet2`
  - Security Group: `alb_sg`
- **Target Groups**:
  - Backend: `alb-target-gr-back`
  - Frontend: `alb-target-gr-front`
- **Listeners**:
  - Backend: `alb_listener_backend` (port `8080`)
  - Frontend: `alb_listener_frontend` (port `3000`)

### ECS Cluster and Services
- **Cluster**: `tictactoe_cluster`
- **Task Definitions**:
  - Backend: `tictactoe_backend_task`
    - Container: `backend` (port `8080`)
  - Frontend: `tictactoe_frontend_task`
    - Container: `frontend` (port `3000`)
- **Services**:
  - Backend: `tictactoe_backend_service`
    - Network: `tictactoe_subnet1` and `tictactoe_subnet2`, SG: `backend_sg`
    - Load Balancer: `alb-target-gr-back`
  - Frontend: `tictactoe_frontend_service`
    - Network: `tictactoe_subnet1` and `tictactoe_subnet2`, SG: `frontend_sg`
    - Load Balancer: `alb-target-gr-front`

### Outputs
- **Backend URL**: `http://${aws_alb.main.dns_name}:8080`
- **Frontend URL**: `http://${aws_alb.main.dns_name}:3000`

## Preview

Screenshots of configured AWS services. Screenshots of your application running.

![Sample image](img/sample-image.png)

## Reflections

- What did you learn?
  - how to define app architecture using fargate and ebs
- What obstacles did you overcome?
  - passing backend address to frontend
  - browser caching frontend code
- What did you help most in overcoming obstacles?
  - peers advice
  - consultation with the teacher
- Was that something that surprised you?
  - longevity of the process of application and destruction in terraform  :(((
