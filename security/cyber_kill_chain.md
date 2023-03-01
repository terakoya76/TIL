# Cyber Kill Chain

## What is
cf. https://speakerdeck.com/yamamo/cndt2020

### 偵察(Reconnaissance)

標的となる個人、組織を調査する。たとえば、インターネット、メール情報、組織への潜入等が挙げられる。

対策

- 検知：
- 阻止：FW, ACL

### 武器化(Weaponization)

攻撃のためのエクスプロイトキットやマルウェア等を作成する。

対策

- 検知：IDS, EDR, SIEM
- 阻止：IPS, AntiVirus

### デリバリ(Delivery)

マルウェアを添付したメールや悪意あるリンク付きメールをしかける。また、直接対象組織のシステムへアクセスする。

対策

- 検知：IDS, EDR, SIEM, Sandbox
- 阻止：Network Separation, Mail Gateway, HTTP Filtering
- 中断：AntiVirus

### エクスプロイト(Exploitation)

標的にマルウェア等攻撃ファイルを実行させる。または、悪意あるリンクにアクセスさせ、エクスプロイトを実行させる。

対策

- 検知：Host-IDS, EDR, Sandbox
- 阻止：Vulnerability Management, AntiVirus
- 中断：不正プログラムの実行防止

### インストール(Installation)

エクスプロイトを成功させ、標的がマルウェアに感染する。これでマルウェア実行可能となる。

対策

- 検知：Host-IDS, EDR, Sandbox
- 阻止：
- 中断：AntiVirus

### C&C(Command & Control)

マルウェアとC&Cサーバが通信可能となり、リモートから標的への操作が可能となる。

対策

- 検知：Host-IDS, EDR, SIEM
- 阻止：FW, ACL, HTTP Filtering
- 中断：IPS

### 目的の実行(Actions on Objectives)

情報搾取や改ざん、データ破壊、サービス停止等、攻撃者の目的が実行される。

対策

- 検知：EDR, SIEM
- 阻止：
- 中断：DLP

## Solution

### FW
* https://smoothwall.org/
* https://vyos.io/
* https://www.ipfire.org/

### ACL

### Network Separation

### EDR
* https://github.com/wazuh/wazuh

### SIEM
* https://siemonster.com/

### Filtering (WAF)
* https://github.com/squid-cache/squid

### IDS
* https://github.com/OISF/suricata
* https://github.com/falcosecurity/falco

### IPS
* https://github.com/wazuh/wazuh
* https://github.com/falcosecurity/falco

### AntiVirus
* https://github.com/wazuh/wazuh
* https://github.com/falcosecurity/falco

### Vulnerability Management
* https://github.com/future-architect/vuls
* https://github.com/aquasecurity/trivy

### DLP

