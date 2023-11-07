# Cloudrun request_count

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

## Usage

```bash
pushd cloud/gcp/usages/cloudrun-request-count

bundle install

filter=xxx
log=result.csv

for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  bundle exec ruby check.rb ${proj} >> ${log}
done
```
