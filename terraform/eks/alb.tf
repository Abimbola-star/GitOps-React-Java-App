# alb.tf

resource "aws_iam_policy" "alb_ingress_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for ALB ingress controller"
  policy      = file("${path.module}/alb-admin-policy.json")
}

resource "aws_iam_role" "alb_controller_irsa" {
  name = "eks-alb-ingress-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = module.eks.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attach" {
  role       = aws_iam_role.alb_controller_irsa.name
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
}

# Commented out to resolve dependency issues during destroy
# resource "kubernetes_service_account" "aws_load_balancer_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_irsa.arn
#     }
#   }
# }
# 
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   version    = "1.7.1"
# 
#   set {
#     name  = "clusterName"
#     value = var.cluster_name
#   }
# 
#   set {
#     name  = "region"
#     value = var.aws_region
#   }
# 
#   set {
#     name  = "vpcId"
#     value = module.vpc.vpc_id
#   }
# 
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }
# 
#   set {
#     name  = "serviceAccount.name"
#     value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
#   }
# 
#   depends_on = [
#     aws_iam_role_policy_attachment.alb_controller_policy_attach,
#     kubernetes_service_account.aws_load_balancer_controller
#   ]
# }