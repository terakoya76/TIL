# drift check

plan all-dirs and detect non-zero return project
```bash
CONFIG_FILE="versions.tf"
MAX_PROJECT_PARALLELISM=50
DEFAULT_BRANCH="main"

log_path() {}
exitcode_path() {}

all_dir() {
    result=""

    for d in $(find . -type f -name ${CONFIG_FILE} | grep -v .terraform | sort); do
      dir=${d%/*}
      result="${result} ${dir#./}"
    done

    echo ${result}
}

plan_in_dir() {
    local proj="$1"
    local log_file="$2"
    local exitcode_file="$3"

    cd ${proj}
    terraform init >>${log_file} 2>&1
    terraform version >>${log_file} 2>&1
    terraform providers >>${log_file} 2>&1
    terraform plan -detailed-exitcode >>${log_file} 2>&1
    local code=$?

    echo ${code} > ${exitcode_file}
}

for d in $(all_dirs); do
    while :
    do
        curr_jobs=$(jobs | wc -l)
        if [ ${curr_jobs} -gt ${MAX_PROJECT_PARALLELISM} ]; then
            sleep 10
        else
            plan_in_dir ${d} ${log_path} ${exitcode_path} &
            break
        fi
    done
done

wait

for d in $(all_dirs); do
    plan_code=$(cat ${exitcode_path})
    if [ ${plan_code} -eq 0 ]; then
        echo "no drift on ${d}"
    else
        echo "drift detected on ${d} by plan exit ${plan_code}"
        pushd ${d}

        current_epoch=$(date +%s)
        git checkout -b "pull/drift-detected-${current_epoch}"

        echo ${current_epoch} > drift-detected.txt
        git config --global user.name "user"
        git config --global user.email "email"
        git add drift-detected.txt
        git commit -m "put drifted-mark"
        hub pull-request -p -f -m "[drift-check] detected drifts on ${d}" -m "Please fix drifts and delete \`drift-detected.txt\`" -b ${DEFAULT_BRANCH} -a "hoge" -l "drift detected"

        git checkout ${DEFAULT_BRANCH}
        popd

        sleep 1
    fi
done
```
