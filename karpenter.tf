# # Deploying default provisioner and default-lt (using launch template) for Karpenter autoscaler
data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "files/default_provisioner*.yaml" # without launch template
  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = "${local.name}-${local.node_group_name}"
    eks-cluster-id          = local.name
    eks-vpc_name            = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value

  depends_on = [module.aws_controllers]
}

# Creates Launch templates for Karpenter
module "karpenter_launch_templates" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.0.7/modules/launch-templates"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  launch_template_config = {
    linux = {
      ami                    = data.aws_ami.eks.id
      launch_template_prefix = "karpenter"
      iam_instance_profile   = module.eks_blueprints.managed_node_group_iam_instance_profile_id[0]
      vpc_security_group_ids = [module.eks_blueprints.worker_node_security_group_id]
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 200
        }
      ]
    }

    # bottlerocket = {
    #   ami                    = data.aws_ami.bottlerocket.id
    #   launch_template_os     = "bottlerocket"
    #   launch_template_prefix = "bottle"
    #   iam_instance_profile   = module.eks_blueprints.managed_node_group_iam_instance_profile_id[0]
    #   vpc_security_group_ids = [module.eks_blueprints.worker_node_security_group_id]
    #   block_device_mappings = [
    #     {
    #       device_name = "/dev/xvda"
    #       volume_type = "gp3"
    #       volume_size = 200
    #     }
    #   ]
    # }
  }

  tags = merge(local.tags, { Name = "karpenter" })
}
