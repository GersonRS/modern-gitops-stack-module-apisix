locals {
  # domain            = format("apisix.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))
  # domain_controller = format("apisix-controller.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))
  # domain_admin      = format("apisix-admin.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))

  helm_values = [{
    useDaemonSet = false
    replicaCount = var.replicas
    # resources    = {}
    autoscaling = {
      enabled = false
    }
    service = {
      type = "LoadBalancer"
    }
    # ingress = {
    #   enabled = true
    #   annotations = {
    #     "cert-manager.io/cluster-issuer" = "${var.cluster_issuer}"
    #   }
    #   hosts = [{
    #     host  = local.domain
    #     paths = ["/"]
    #   }]
    #   tls = [
    #     {
    #       hosts      = [local.domain]
    #       secretName = "apisix-tls"
    #     }
    #   ]
    # }
    # control = {
    #   ingress = {
    #     enabled = true
    #     annotations = {
    #       "cert-manager.io/cluster-issuer" = "${var.cluster_issuer}"
    #     }
    #     hosts = [{
    #       host  = local.domain_controller
    #       paths = ["/*"]
    #     }]
    #     tls = [
    #       {
    #         hosts      = [local.domain_controller]
    #         secretName = "apisix-controller-tls"
    #       }
    #     ]
    #   }
    # }
    metrics = {
      serviceMonitor = {
        enabled   = var.enable_service_monitor
        namespace = "ingress-apisix"
      }
    }
    apisix = {
      deployment = {
        role = "traditional"
        role_traditional = {
          config_provider = "yaml"
        }
      }
      admin = {
        credentials = {
          admin  = resource.random_password.password_secret.result
          viewer = resource.random_password.password_secret.result
        }
        # ingress = {
        #   enabled = true
        #   annotations = {
        #     "cert-manager.io/cluster-issuer" = "${var.cluster_issuer}"
        #   }
        #   hosts = [{
        #     host  = local.domain_admin
        #     paths = ["/*"]
        #   }]
        #   tls = [
        #     {
        #       hosts      = [local.domain_admin]
        #       secretName = "apisix-admin-tls"
        #     }
        #   ]
        # }
      }
      prometheus = {
        enabled = var.enable_service_monitor
      }
      # plugins = []
    }
    etcd = {
      enabled = false
    }
    ingress-controller = {
      enabled = true
      autoscaling = {
        enabled = true
      }
      deployment = {
        replicas = 1
        # resources = {}
      }
      config = {
        logLevel = "info"
        provider = {
          type = "apisix-standalone"
        }
        kubernetes = {
          ingressClass        = "apisix"
          defaultIngressClass = true
        }
      }
      gatewayProxy = {
        createDefault = true
        provider = {
          controlPlane = {
            auth = {
              adminKey = {
                value = resource.random_password.password_secret.result
              }
            }
          }
          # plugins = []
        }
      }
      apisix = {
        adminService = {
          namespace = "ingress-apisix"
        }
      }
      serviceMonitor = {
        enabled   = var.enable_service_monitor
        namespace = "ingress-apisix"
      }
    }
  }]
}
