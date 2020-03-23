# Sentry API

## Unresolved Issue Count
cf. https://stackoverflow.com/questions/73666362/need-help-to-understand-the-documentation-of-sentry-api
```python
#!/usr/bin/env python3

import os
import requests

token = os.environ['TOKEN']
org = os.environ['ORGANIZATION_SLUG']

projects_url = 'https://sentry.io/api/0/projects/'
headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

print('Start to fetch projects')
projects = []
r = requests.get(url=projects_url, headers=headers, params={}, verify=False)
data = r.json()
for req in data:
    projects.append(req['slug'])

while r.links.get('next', {}).get('results') == "true":
    r = requests.get(r.links['next']['url'], headers=headers, params={}, verify=False)
    data = r.json()
    for req in data:
        projects.append(req['slug'])

print('Start to fetch issues')
issues = {}
for prj in projects:
    states = {
        'unresolved': 0,
        'resolved': 0,
        'ignored': 0,
    }

    for state in states:
        issues_url = f'https://sentry.io/api/0/projects/{org}/{prj}/issues/?query=is:{state}'
        r = requests.get(url=issues_url, headers=headers, params={}, verify=False)
        data = r.json()
        states[state] += len(data)

        while r.links.get('next', {}).get('results') == "true":
            r = requests.get(r.links['next']['url'], headers=headers, params={}, verify=False)
            data = r.json()
            states[state] += len(data)

    issues[prj] = states

for prj in issues:
    unresolved = issues[prj]['unresolved']
    resolved = issues[prj]['resolved']
    ignored = issues[prj]['ignored']
    print(f'{prj},{unresolved},{resolved},{ignored}')
```

## Fetch Project Stats
```python
#!/usr/bin/env python3

import os
import requests
import datetime
import time

token = os.environ['TOKEN']
org = os.environ['ORGANIZATION_SLUG']

projects_url = 'https://sentry.io/api/0/projects/'
headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

print('Start to fetch projects')
projects = []
r = requests.get(url=projects_url, headers=headers, params={}, verify=False)
data = r.json()
for req in data:
    projects.append(req['slug'])

while r.links.get('next', {}).get('results') == "true":
    r = requests.get(r.links['next']['url'], headers=headers, params={}, verify=False)
    data = r.json()
    for req in data:
        projects.append(req['slug'])

print('Start to fetch events')
events = {}
for prj in projects:
    stats = {
        'received': 0,
        'rejected': 0,
        'blacklisted': 0,
        'generated': 0,
    }

    for stat in stats:
        today = datetime.date.today()
        month_ago = (today.replace(day=1) - datetime.timedelta(days=1)).replace(day=today.day)
        since = int(time.mktime(month_ago.timetuple()))
        until = time.time()

        events_url = f'https://sentry.io/api/0/projects/{org}/{prj}/stats/?stat={stat}&resolution=1d&since={since}&until={until}'
        r = requests.get(url=events_url, headers=headers, params={}, verify=False)
        data = r.json()
        for req in data:
            stats[stat] += req[1]

        while r.links.get('next', {}).get('results') == "true":
            r = requests.get(r.links['next']['url'], headers=headers, params={}, verify=False)
            data = r.json()
            for req in data:
                stats[stat] += req[1]

    events[prj] = stats

for prj in events:
    received = events[prj]['received']
    rejected = events[prj]['rejected']
    blacklisted = events[prj]['blacklisted']
    generated = events[prj]['generated']
    print(f'{prj},{received},{rejected},{blacklisted},{generated}')
```
