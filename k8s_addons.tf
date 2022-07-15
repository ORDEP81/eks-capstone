module "kubernetes-addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.0.9/modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.
  argocd_applications = {
    addons    = local.addon_application
    workloads = local.workload_application
  }

  argocd_helm_config = {
    values = [templatefile("files/argocd-values.yaml", {})]
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------
  enable_aws_cloudwatch_metrics        = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_for_fluentbit             = false
  enable_cert_manager                  = false
  enable_cluster_autoscaler            = false
  enable_ingress_nginx                 = false
  enable_keda                          = false
  enable_prometheus                    = false
  enable_traefik                       = false
  enable_vpa                           = false
  enable_yunikorn                      = false
  enable_argo_rollouts                 = false

  depends_on = [module.eks_blueprints.managed_node_groups, module.aws_controllers]

  tags = local.tags
}


