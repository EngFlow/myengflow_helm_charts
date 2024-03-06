## Helm values

### Required values

- `allowedUsers`: list of strings. The email addresses and email domains of users allowed to log in
  and use the cluster. Examples:

    - `["alice", "bob"]` when using `secrets.htpasswd.secretName` and these are user names in
      "htpasswd.txt".
    - `["alice@example.com", "*@mycompany.com"]` when using `secrets.oidc.secretName` and these are
      allowed email addresses or email domains.

    **Caution**: We strongly recommend not to add `"*"` as an entry: this would allow anyone to log
    in (e.g. if the cluster's endpoint is public).

- `clusterUuid`:
  - `.fromValue`:
    - `.value`: string. The cluster UUID you received when signing up on <https://my.engflow.com/>

- `storage`:
  - `.storageClassName`: string. Kubernetes StorageClass name for the disk.
      - On GCP (GKE) and Minikube: set to `standard`, or to an existing StorageClass of your choice.
      - On AWS (EKS): set to an existing StorageClass (usually called `ebs-sc`) with the
        `ebs.csi.aws.com` provisioner, or to an existing StorageClass of your choice.

### Optional values

- `auth`:
  - `.grpc`: string, one of [`none`, `deny`, `mtls`]. The type of gRPC client authentication to use.
    Values:
    - `none`: There is no authentication; anyone can make gRPC requests.
    - `deny`: Nobody can make gRPC requests.
    - `mtls`: Clients can authenticate either with an mTLS client certificate, or with a JWT token.
      Both can be downloaded from the cluster's UI, on the "Getting started" page. If this option is
      used, then server TLS must also be configured (see `secrets.tls.secretName`).
  - `.http`: list of strings, default: `[]`. The type of HTTP client authentication to use. Values:
    - `none`: There is no authentication; anyone can make HTTP requests. If specified, then the list
      cannot contain any other value.
    - `deny`: Nobody can make gRPC requests. If specified, then the list cannot contain any other
      value.
    - `basic`: Clients can log in using HTTP Basic authentication, i.e. with user name and password
      pairs. If this is enabled, then the htpasswd secret must also be configured (see
      `secrets.htpasswd.secretName`). This value can be combined with `oidc`.
    - `oidc`: Clients can log in using OIDC (Open ID Connect), i.e. via a IdP (Identity Provider)
      such as Google and Okta. If this is enabled, then the oidc secret must also be configured (see
      `secrets.oidc.secretName`). This value can be combined with `basic`.

- `endpoint`:
  - `.createService`: boolean. Whether to create a Service (`type=LoadBalancer`) resource that
    exposes the endpoint.

- `storage`:
  - `.size`: string, default: `100Gi`. Size of the disk, as a [Quantity][1].

- `secrets`:
  - `.tls`:
    - `.secretName`: string. Name of an existing Secret with the server TLS key + cert.

      Secret type must be `kubernetes.io/tls`.

      This value must be specified when any authentication is enabled, i.e. when `auth.grpc="mtls"`,
      and/or when `auth.http` contains `basic` and/or `oidc`.

      - If present, "main.yaml" starts the app with `--tls_certificate` and `--tls_key` pointing to
        the named secret, and clients can talk to the service over https/grpcs.
      - If absent, "main.yaml" starts the app with `--insecure=true`, and clients can talk to the
        service over plaintext http/grpc. In this case, no authentication may be enabled, i.e.
        `auth.grpc` and `auth.http` must be empty, or `none`, or `deny`.

  - `mtls_ca`:
    - `.secretName`: string. Name of an existing Secret with the CA key + cert that signs client
      certificates and JWTs. If left empty, then a cluster-specific CA is used, which is generated
      on the first-time installation (and kept the same across upgrades).

      Secret type must be `kubernetes.io/tls`.

      This value is only used when `auth.grpc="mtls"`.

      - If present, then "main.yaml" starts the app with `--client_auth=mtls` and
        `--tls_trusted_{certificate,key}` pointing to the named secret.
      - If absent, then a Helm install hook generates a new client CA and inserts it as a Secret
        called `mtls-ca`, and uses it like a user-specified secret.

  - `.oidc`:
    - `.secretName`: string. Name of an existing Secret with the OIDC config (JSON data).

      Secret type must be `Opaque`; the single data entry must be `oidc-config.json`. Format is
      documented at <https://docs.engflow.com/re/config/options.html#oidc_config>.

      This value is only used when `auth.http=["oidc"]` or `auth.http=["oidc", "basic"]`.

      If present, then the UI enables OIDC auth: "main.yaml" starts the app with
      `--http_auth+=oidc_login` and `--oidc_config` points to the named secret.

  - `.htpasswd`:
    - `.secretName`: string. Name of an existing Secret with the Basic auth usernames and hashed
      passwords.

      Secret type must be `Opaque`; the single data entry must be `htpasswd.txt`.

      This value is only used when `auth.http=["basic"]` or `auth.http=["basic","oidc"]`.

      If present, then the UI enables HTTP Basic auth: "main.yaml" starts the app with
      `--http_auth+=basic` and `--basic_auth_htpasswd` points to the named secret.

- `remoteStorage`: You can set this configuration block to connect MyEngFlow Mini to another Remote
  Execution or Remote Cache service ("remote backend"), and use MyEngFlow Mini just as a BES backend
  and UI.

  - `.endpoint`: string, optional. Address of the "remote backend" in `{protocol}://{host}:[port]`
    format, e.g. `grpc://127.0.0.1:12345` or `grpcs://example.cluster.engflow.com`

    If specified, then MyEngFlow Mini will be configured to download files (e.g. referenced by build
    event streams) from this service.

  - `.serverCertCmName`: string, optional. Name of an existing ConfigMap in this namespace.

    Can be used to specify a trusted CA certificate, in case the "remote backend" uses self-signed
    certificates.

    This is only used when `.endpoint` has a value.

    The map must contain a key called `ca.crt` with a value of an X.509 certificate: either the
    remote backend's own certificate or that of its issuer.

    MyEngFlow Mini will trust this certificate (and certificates signed by it) when talking to the
    remote backend.

  - `.clientAuth`:
    - `.method`: string, one of [`none`, `header`, `mtls`]. Default is `none`. The client
      authentication method used for the `.endpoint`.

      Only used when `.endpoint` has a value.

      Values:
      - `none`: The remote cluster requires no client authentication.
      - `header`: Authenticate using HTTP request headers.
      - `mtls`: Authenticate using mTLS client credentials.

    - `.secretName`: string. Name of an existing Secret with the client credentials.

      Only used when `.endpoint` has a value, and `.method` is `header` or `mtls`.

      Values:
      - If `.method="header"`, then the Secret type must be `Opaque`; its single data entry must be
        `auth.json`, containing JSON data for the HTTP authorization header(s) and value(s).

        Format: `{"header1":["value1"],"header2":["value2","value3"]}`. All headers will be
        sent in requests.

        Example values:
        - `{"Authorization":["Basic YWxpY2U6bXlzZWNyZXQ="]}` (the value after `Basic` is a
          base64-encoded string of `username:password`)
        - `{"x-engflow-auth-method":["jwt-v0"],"x-engflow-auth-token":["eyJh(...)1o"]}`

      - If `.method="mtls"`, then the Secret type must be `kubernetes.io/tls`. The key must be in
        PKCS#8 PEM format, and the certificate must be in X.509 PEM format and contain a single
        certificate (not a chain).

[1]: https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/#Quantity
