# Useful Expressions
## Inventory loop
extracts prop A filtered by prop B from test_group
```jinja2
- name: task
  command: 'echo {{ hostvars[item]["prop_a"] }}'
  loop: '{{ groups["test_group"] }}'
  when: hostvars[item]['prop_b'] == "hoge"
```

exec tasks for specific groups
```jinja2
- import_tasks: mytask.yml
  when: '"group_a" in group_names
    or "group_b" in group_names'
```

extracts ansible_host from all servers
```jinja2
{% for host in groups['all'] %}
[servers.{{ hostvars[host]['ansible_host'] | regex_replace('\.', '-') }}]
host = "{{ hostvars[host]['ansible_host'] }}"
{% endfor %}
```

## Other
subnet mask from CIDR
```jinja2
addresses: [{{ ip }}/{{ mycidr.split('/') | last }}]
```
