local beteps = import 'ksonnet-util/kausal.libsonnet';
local secrets_patch = {
  spec: {
    template: {
      spec: {
        imagePullSecrets: [
          { name: 'gcr-json-key' },
          { name: 'ghcr-json-key' },
        ],
      },
    },
  },
};
{
  _config:: {
    port: 4000,
    name: 'beteps',
    image: std.extVar('image'),
    beteps_config:
      {
        PORT: '4000',
        RELEASE_COOKIE: 'cookie',
        FILESYSTEM_DIR_PATH: '/tmp/beteps',
        STORAGE_ADAPTER: 'cockroach',
        KAFKA_HOSTS: 'redpanda.redpanda.svc.cluster.local:9092',
        BETFRONT_TBII_URL: 'https://beteps.4781c9f1c6f17815.erlang-solutions.com',
        CACHE_EXPIRATION: '3600000',
        COCKROACH_DATABASE: 'betepsagtk',
        COCKROACH_HOSTNAME: ' cockroach-cockroachdb.cockroachdb.svc.cluster.local',
        COCKROACH_PASSWORD: '',
        COCKROACH_POOL: '10',
        COCKROACH_PORT: '26257',
        COCKROACH_TABLE_NAME: 'events',
        COCKROACH_USERNAME: 'root',
        COCKROACH_SSL: false,
        COCKROACH_SSL_CERT_FILE: null,
        COCKROACH_SSL_SECRET: null,
      },
    secrets: {
      top: 'sekrit',
    },
    otel_config: {
      'otel-collector-config.yml': importstr 'otel-collector-config.yml',
    },
    client_cert_tls_secret_name: 'cockroachdb.client.root',
  },
  deploy: [
    beteps.namespace($._config.name),
    beteps.secrets($._config.name, $._config.secrets),
    beteps.configMap($._config.name, 'otel-config', $._config.otel_config),
    beteps.configMap($._config.name, 'beteps-config', $._config.beteps_config),
    beteps.service_account($._config.name),
    beteps.service($._config.name),
    std.mergePatch(beteps.deployment($._config), secrets_patch),
  ],
}
