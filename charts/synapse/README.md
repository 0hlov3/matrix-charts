# Matrix Synapse Helm (WIP - Do not Use yet)

## Create the Namespace
```shell
kubectl create namespace synapse
```

## Create the Secrets
### registration_shared_secret
```shell
kubectl create secret --namespace synapse generic synapse-registration-secret --from-literal=registration-shared-secret="$(openssl rand -hex 16)"
```
### macaroon_secret_key
```shell
kubectl create secret --namespace synapse generic synapse-macaroon-secret --from-literal=macaroon-secret-key="$(openssl rand -hex 16)"
```
### email
```shell
kubectl create secret --namespace synapse generic synapse-mail-secret \
  --from-literal=smtp-host=${MAILSERVER} \
  --from-literal=smtp-port=${MAILSERVER_PORT} \
  --from-literal=smtp-user=${MAILSERVER_USER} \
  --from-literal=smtp-pass=${MAILSERVER_PASSWORD}
```

### Redis
```shell
kubectl create secret --namespace synapse generic synapse-redis-secret --from-literal=redis-pass="$(openssl rand -hex 16)"
```
### PostgreSQL
```shell
kubectl create secret --namespace synapse generic synapse-postgresql-secret --from-literal=username="$(openssl rand -hex 16)" --from-literal=password="$(openssl rand -hex 16)"
```
### If Captcha Enabled
```shell
kubectl create secret --namespace synapse generic synapse-captcha-secret --from-literal=recaptcha-public-key="${SYNAPSE_RECAPTCHA_PUBLIC_KEY}" --from-literal=recaptcha-private-key="${SYNAPSE_RECAPTCHA_PRIVATE_KEY}"
```

## Parameters

### Synapse Image

| Name               | Description                                          | Value                  |
| ------------------ | ---------------------------------------------------- | ---------------------- |
| `image.registry`   | Global Docker image registry                         | `docker.io`            |
| `image.repository` | Global Docker registry secret names as an array      | `matrixdotorg/synapse` |
| `image.pullPolicy` | Global default StorageClass for Persistent Volume(s) | `IfNotPresent`         |
| `image.tag`        | DEPRECATED: use global.defaultStorageClass instead   | `""`                   |

### Synapse signing Key config

| Name                                         | Description                                          | Value             |
| -------------------------------------------- | ---------------------------------------------------- | ----------------- |
| `signingkey.job.enabled`                     | Global Docker image registry                         | `true`            |
| `signingkey.job.storeSecretImage.repository` | Global Docker registry secret names as an array      | `docker.io`       |
| `signingkey.job.storeSecretImage.image`      | Global default StorageClass for Persistent Volume(s) | `bitnami/kubectl` |
| `signingkey.job.storeSecretImage.pullPolicy` | DEPRECATED: use global.defaultStorageClass instead   | `IfNotPresent`    |
| `signingkey.existingSecret`                  | DEPRECATED: use global.defaultStorageClass instead   | `nil`             |
| `signingkey.existingSecretKey`               | DEPRECATED: use global.defaultStorageClass instead   | `signing.key`     |
| `signingkey.resources`                       | DEPRECATED: use global.defaultStorageClass instead   | `{}`              |

### Synapse Config

| Name                                             | Description                                                                                                                                                                                                                                                                                                                                                                                         | Value                                                    |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `synapse.extraCommands`                          | extra Commands to run inside the Synapse Pod                                                                                                                                                                                                                                                                                                                                                        | `{}`                                                     |
| `config.serverName`                              | This sets the public-facing domain of the server.                                                                                                                                                                                                                                                                                                                                                   | `""`                                                     |
| `config.publicBaseurl`                           | The public-facing base URL that clients use to access this Homeserver (not including _matrix/...). This is the same URL a user might enter into the 'Custom Homeserver URL' field on their client. If you use Synapse with a reverse proxy, this should be the URL to reach Synapse via the proxy. Otherwise, it should be the URL to reach Synapse's client HTTP listener (see 'listeners' below). | `nil`                                                    |
| `config.webClientLocation`                       | The absolute URL to the web client which / will redirect to. Defaults to none.                                                                                                                                                                                                                                                                                                                      | `""`                                                     |
| `config.mediaStore.enabled`                      | Enable the media store service in the Synapse master. Defaults to true. Set to false if you are using a separate media store worker.                                                                                                                                                                                                                                                                | `true`                                                   |
| `config.mediaStore.persistence.enabled`          | Enable persistence                                                                                                                                                                                                                                                                                                                                                                                  | `true`                                                   |
| `config.mediaStore.persistence.size`             | Size for the PV                                                                                                                                                                                                                                                                                                                                                                                     | `5Gi`                                                    |
| `config.mediaStore.persistence.accessMode`       | Persistent Volume Access Mode                                                                                                                                                                                                                                                                                                                                                                       | `ReadWriteOnce`                                          |
| `config.registration.enabled`                    | Enable registration for new users. Defaults to false.                                                                                                                                                                                                                                                                                                                                               | `false`                                                  |
| `config.registration.withoutVerification`        | Enable registration without email or captcha verification. Note: this option is not recommended, as registration without verification is a known vector for spam and abuse. Defaults to false. Has no effect unless enable_registration is also enabled.                                                                                                                                            | `false`                                                  |
| `config.database.txnLimit`                       | gives the maximum number of transactions to run per connection before reconnecting. Defaults to 0, which means no limit.                                                                                                                                                                                                                                                                            | `0`                                                      |
| `config.database.cpMin`                          | used to configure the Twisted connection pool                                                                                                                                                                                                                                                                                                                                                       | `5`                                                      |
| `config.database.cpMax`                          | used to configure the Twisted connection pool                                                                                                                                                                                                                                                                                                                                                       | `10`                                                     |
| `config.trustedKeyServers[0].server_name`        | The trusted servers to download signing keys from.                                                                                                                                                                                                                                                                                                                                                  | `matrix.org`                                             |
| `config.registrationSharedSecret.existingSecret` | If set, allows registration of standard or admin accounts by anyone who has the shared secret, even if enable_registration is not set.                                                                                                                                                                                                                                                              | `synapse-registration-secret`                            |
| `config.macaroonSecretKey.enabled`               | If none is specified, the registration_shared_secret is used, if one is given; otherwise, a secret key is derived from the signing key.                                                                                                                                                                                                                                                             | `true`                                                   |
| `config.macaroonSecretKey.existingSecret`        | If none is specified, the registration_shared_secret is used, if one is given; otherwise, a secret key is derived from the signing key.                                                                                                                                                                                                                                                             | `synapse-macaroon-secret`                                |
| `config.turn.enabled`                            | If none is specified, the registration_shared_secret is used, if one is given; otherwise, a secret key is derived from the signing key.                                                                                                                                                                                                                                                             | `false`                                                  |
| `config.turn.existingSecret`                     | If none is specified, the registration_shared_secret is used, if one is given; otherwise, a secret key is derived from the signing key.                                                                                                                                                                                                                                                             | `synapse-turn-secret`                                    |
| `config.email.enabled`                           |                                                                                                                                                                                                                                                                                                                                                                                                     | `false`                                                  |
| `config.email.existingSecret`                    |                                                                                                                                                                                                                                                                                                                                                                                                     | `synapse-mail-secret`                                    |
| `config.email.forceTLS`                          |                                                                                                                                                                                                                                                                                                                                                                                                     | `true`                                                   |
| `config.email.requireTransportSecurity`          |                                                                                                                                                                                                                                                                                                                                                                                                     | `true`                                                   |
| `config.email.enableTLS`                         |                                                                                                                                                                                                                                                                                                                                                                                                     | `true`                                                   |
| `config.email.notifFrom`                         |                                                                                                                                                                                                                                                                                                                                                                                                     | `Your Friendly %(app)s homeserver <noreply@example.com>` |
| `config.email.enableNotifs`                      |                                                                                                                                                                                                                                                                                                                                                                                                     | `true`                                                   |
| `config.email.client_base_url`                   |                                                                                                                                                                                                                                                                                                                                                                                                     | `http://localhost/riot`                                  |
| `config.captcha.enabled`                         |                                                                                                                                                                                                                                                                                                                                                                                                     | `false`                                                  |
| `config.captcha.existingSecret`                  |                                                                                                                                                                                                                                                                                                                                                                                                     | `synapse-captcha-secret`                                 |
| `extraConfig`                                    |                                                                                                                                                                                                                                                                                                                                                                                                     | `{}`                                                     |

### Database Config

| Name                                | Description                      | Value                                     |
| ----------------------------------- | -------------------------------- | ----------------------------------------- |
| `sqlite.enabled`                    | Defines if SQLite should be Used | `false`                                   |
| `sqlite.persistence.enabled`        | Enable persistence               | `true`                                    |
| `sqlite.persistence.size`           | Size for the PV                  | `5Gi`                                     |
| `sqlite.persistence.accessMode`     | Persistent Volume Access Mode    | `ReadWriteOnce`                           |
| `postgreSQLexternal.enabled`        |                                  | `true`                                    |
| `postgreSQLexternal.host`           |                                  | `postgresql.postgresql.svc.cluster.local` |
| `postgreSQLexternal.port`           |                                  | `5432`                                    |
| `postgreSQLexternal.database`       |                                  | `synapse`                                 |
| `postgreSQLexternal.existingSecret` |                                  | `synapse-postgresql-secret`               |

### Redis Config

| Name                                   | Description                                       | Value                  |
| -------------------------------------- | ------------------------------------------------- | ---------------------- |
| `redis.enabled`                        | Defines if Redis should be Used                   | `false`                |
| `redis.auth.enabled`                   | Defines if Redis should be Used                   | `true`                 |
| `redis.auth.existingSecret`            | Defines the Secret for Redis credentials          | `synapse-redis-secret` |
| `redis.auth.existingSecretPasswordKey` | Defines the key where to get the Credentials from | `redis-pass`           |
| `redis.architecture`                   |                                                   | `standalone`           |
| `redis.master.persistence.enabled`     | Enable persistence                                | `false`                |
| `redis.master.persistence.size`        | Size for the PV                                   | `8Gi`                  |
| `redis.master.service.ports.redis`     | Persistent Volume Access Mode                     | `6379`                 |

### Ingress

| Name                  | Description                                                                                                                      | Value   |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable ingress record generation for Keycloak                                                                                    | `false` |
| `ingress.className`   | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`    |
| `ingress.annotations` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`    |
| `ingress.tls`         | Enable TLS configuration for the hostname defined at ingress.hostname parameter                                                  | `[]`    |

