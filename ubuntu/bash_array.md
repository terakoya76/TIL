# Bash Array

## Basic
```bash
$ arr1=(a b c)

$ echo $arr1
a

$ echo ${arr1[@]}
a b c

$ echo ${#arr1[@]}
3

$ for i in $(seq 0 2); do echo ${arr1[$i]}; done
a
b
c
```

## bind from string
```bash
$ arr2=$(ls)
$ for i in $(seq 0 6); do echo ${arr2[$i]}; done
ansible.cfg group_vars inventory playbooks README.md roles setup.sh

$ ls | read -a arr3
$ for i in $(seq 0 6); do echo ${arr3[$i]}; done
ansible.cfg
group_vars
inventory
playbooks
README.md
roles
setup.sh
```
