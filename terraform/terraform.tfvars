### configurations
db-backup-c4gh-public-key-path = ""
kubeconfig-path                = ""

### container tags
sda-services-backup-version = "v0.1.111"

### helm chart versions
sda-db-version  = "2.0.20"
sda-mq-version  = "2.0.20"
sda-svc-version = "3.0.13"

### ingress
### ingress-base is the root domain, all exposed services will be reachable as sub domains.
ingress-base                   = ""
ingress-class                  = "nginx"
ingress-deploy                 = true
letsencrypt-issuer             = "letsencrypt-production"
letsencrypt-notification-email = ""

### Kubernetes namespace where everything should be deployed
namespace = ""

### RabbitMQ admin user
rabbitmq-admin-user = "admin"

### Storage backend configuration
oidc-provider      = "https://login.aai.lifescience-ri.eu/oidc"
oidc-client-id     = ""
oidc-client-secret = ""

repository-c4gh-key-path        = ""
repository-c4gh-passphrase      = ""
repository-c4gh-public-key-path = ""

s3URL       = ""
s3AccessKey = ""
s3SecretKey = ""
### the S3 backup loation stores both archived files and the database backups
s3BackupURL       = ""
s3BackupAccessKey = ""
s3BackupSecretKey = ""

api-admins = {
  "policy" : [
    {
      "role" : "admin",
      "path" : "/c4gh-keys/*",
      "action" : "(GET)|(POST)|(PUT)"
    },
    {
      "role" : "admin",
      "path" : "/file/verify/:accession",
      "action" : "PUT"
    },
    {
      "role" : "admin",
      "path" : "/dataset/verify/:dataset",
      "action" : "PUT"
    },
    {
      "role" : "submission",
      "path" : "/datasets/*",
      "action" : "GET"
    },
    {
      "role" : "submission",
      "path" : "/dataset/*",
      "action" : "(POST)|(PUT)"
    },
    {
      "role" : "submission",
      "path" : "/file/ingest",
      "action" : "POST"
    },
    {
      "role" : "submission",
      "path" : "/file/accession",
      "action" : "POST"
    },
    {
      "role" : "submission",
      "path" : "/file/*",
      "action" : "DELETE"
    },
    {
      "role" : "submission",
      "path" : "/users",
      "action" : "GET"
    },
    {
      "role" : "submission",
      "path" : "/users/:username/files",
      "action" : "GET"
    },
    {
      "role" : "*",
      "path" : "/datasets",
      "action" : "GET"
    },
    {
      "role" : "*",
      "path" : "/files",
      "action" : "GET"
    }
  ],
  "roles" : [
    {
      "role" : "admin",
      "rolebinding" : "submission"
    },
    # Here add the users which should be admin or submission roles
    # Example
    # {
    #   "role" : "${USER_ID]",
    #   "rolebinding" : "admin"
    # },
  ]
}