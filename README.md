# BOSH Release for Redis

Forked from [cloudfoundry-community/redis-boshrelease](https://github.com/cloudfoundry-community/redis-boshrelease). 
Huge thanks to the original authors and community contributors! 🙏

This BOSH release providing **Redis** as a service and can be deployed in the following modes:
- **single-node** (standalone),
- **HA cluster with Sentinel** for automatic failover and high availability.

## Examples

The repository contains sample deployment manifests in [`examples/`](./examples):
- **Single-node Redis** manifest [`redis-single.yml`](./examples/manifests/redis-single.yml)
- **Redis + Sentinel HA cluster** manifest [`redis-ha.yml`](./examples/manifests/redis-ha.yml)
- **Ops file for additional users** manifest [`additional-users.yml`](./examples/manifests/ops/additional-users.yml)
- **The additional users tests script** [`examples/additional-users.sh`](./examples/additional-users-tests.sh)


## Features

- **Up to date Redis**  
  Built from the latest stable Redis series.

- **Sentinel support**  
  Automatic leader election and failover, or simple standalone mode.

- **User management via ACL**  
  Fine-grained access control for multiple users (e.g. admin, read-only, per-app accounts).

- **Prometheus metrics exporter**  
  Integrated [`redis_exporter`](https://github.com/oliver006/redis_exporter) job to expose Redis metrics for Prometheus/Grafana monitoring.

## Notes

- This fork currently has **no CI/CD pipeline** – builds and releases are managed manually.
- Focus is on a clean, production-ready configuration with sensible defaults and BOSH templating.
