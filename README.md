# HTML Games

    Purpose:
        
        - Deploy multiple HTML games from a single POC
          using Path-Based Routing

    
    Basic Starting Architecture ( Bottom-Up ):

        - VPC to house the AWS resources

        - EC2 instances running the workload

        - ASG maintaining workload balance

        - ALB routing incoming traffic to correct instance
          using Path-Based Routing

        - Route53 DNS to provide User with single POC

    
    Secondary Goal:

        - Migrate to ECS Cluster

    
    End Goal:

        - Migrate to EKS Cluster

        - Utilize AWS Load Balancer as Ingress Controller
