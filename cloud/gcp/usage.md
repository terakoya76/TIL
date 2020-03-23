# Usage on GCP

## Add project configuration

```bash
filter=xxx
account=xxx
for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  gcloud config configurations create ${proj}
  gcloud config set project ${proj}
  gcloud config set account ${account}
done
```

## Cloudrun

### instance_count
```bash
pushd cloud/gcp/usages/cloudrun-instance-count

bundle install

filter=xxx
log=result.csv

for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  bundle exec ruby check.rb ${proj} >> ${log}
done
```

### request_count
```bash
pushd cloud/gcp/usages/cloudrun-request-count

bundle install

filter=xxx
log=result.csv

for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  bundle exec ruby check.rb ${proj} >> ${log}
done
```

## Cloud Logging

### Log Bytes Ingested
```bash
pushd cloud/gcp/usages/logging-bytes-ingested

bundle install

filter=xxx
log=result.csv

for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  bundle exec ruby check.rb ${proj} >> ${log}
done
```
