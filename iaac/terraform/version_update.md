# Terraform MonoRepo Version Update

## show proj and its terraform version
```bash
$ find . -type f -name .terraform-version \
| xargs  -I{}  bash -c 'echo -n "{} - "; cat {}' \
| sort
```

find proj which uses version `0.12.x`
```bash
$ find . -type f -name .terraform-version \
| xargs  -I{}  bash -c 'echo -n "{} - "; cat {}' \
| grep "0.12" \
| sort
```

## find proj which does not have `required_providers` setting
* https://github.com/terraform-linters/tflint/blob/master/docs/rules/terraform_required_version.md
* https://github.com/terraform-linters/tflint/blob/master/docs/rules/terraform_required_providers.md
* https://github.com/terraform-linters/tflint/blob/master/docs/rules/terraform_unused_required_providers.md

```bash
$ find . -type f -name provider.tf \
| xargs  -I{}  bash -c 'echo -n "{} "; grep required_providers {} | xargs echo -n; echo ""' \
| grep -v required_providers \
| sort
```

## show proj and its aws-provider version
```bash
$ find . -type f -name provider.tf \
| xargs  -I{}  bash -c 'echo -n "{} "; grep -E "\s+version" {} | xargs echo -n; echo ""' \
| sort
```

show proj which uses aws-provider version `2.x.x`
```bash
$ find . -type f -name provider.tf \
| xargs  -I{}  bash -c 'echo -n "{} "; grep -E "\s+version" {} | xargs echo -n; echo ""' \
| grep "~> 2" \
| grep -v .terraform \
| sort
```

## update all `0.12.x` proj upto `0.13.x`
* https://github.com/minamijoyo/tfupdate

```bash
# create 0.14.x proj list to be ignored
$ find . -type f -name .terraform-version \
| xargs  -I{}  bash -c 'echo -n "{} - "; cat {}' \
| grep "0.14" \
| sort \
| cut -d/ -f2 > ignore.txt

# update all proj to 0.13.x other than some_prefix_* proj
$ tfupdate terraform -v 0.13.5 -r ./ -i "some_prefix_*"

# reset ignore proj
$ for proj in `cat ignore.txt`; do git checkout ${proj}; done

# update .terraform version manually
$ git status --porcelain | grep "M " | awk '{print $2}' | cut -d/ -f1 > updated.txt
$ for proj in `cat updated.txt`; do echo "0.13.5" > ${proj}/.terraform-version; done

# re-fmt updated proj
$ for proj in `cat updated.txt`; do pushd ${proj}; rm -rf .terraform; terraform init; terraform fmt -recursive; popd; done
```

## lint all projects
```bash
$ result_path=~/lint.txt
$ root=$(pwd)
$ for i in $(find . -type f -name provider.tf | sort)
do
  dir=${i%/*}
  pushd ${dir} >> ${result_path}
  rm -rf .terraform
  tflint --config="${root}/.tflint.hcl" >> ${result_path}
  popd
done
```

## fetch remote module updates
* https://github.com/keilerkonzept/terraform-module-versions
```bash
$ result_path=~/updates.txt
$ for i in $(find . -type f -name provider.tf | sort)
do
  dir=${i%/*}
  echo ${dir} >> ${result_path}
  terraform-module-versions check ${dir} >> ${result_path}
done
```
