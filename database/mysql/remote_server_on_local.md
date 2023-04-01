# VM 上に MySQL を構築
## VM 定義
```Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "forwarded_port", guest: 3306, host: 33060
end
```

## MySQL 設定
Setup
```bash
$ vagrant up
$ vagrant ssh
$ sudo apt update
$ sudo apt install -y mysql-server
$ sudo mysql -uroot -e'select version();'
+-------------------------+
| version()               |
+-------------------------+
| 5.7.32-0ubuntu0.18.04.1 |
+-------------------------+

$ sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf
$ sudo service mysql restart
```

```diff
# bind-address をコメントアウト
- bind-address = 172.0.0.1
+ #bind-address = 172.0.0.1

# hosts_cache を確認するため
+ performance_schema=on
```

User設定
```sql
mysql> CREATE USER myuser IDENTIFIED BY 'mypassword';
mysql> GRANT ALL ON *.* TO myuser@'%' IDENTIFIED BY 'mypassword';
mysql> SHOW GRANTS FOR myuser;
+---------------------------------------------+
| Grants for myuser@%                         |
+---------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'myuser'@'%' |
+---------------------------------------------+
1 row in set (0.00 sec)
```

## local から VM 上の MySQL にアクセス
```bash
$ mysql -h127.0.0.1 -umyuser -pmypassword -P33060
myuser@127.0.0.1 [(none)] > select * from performance_schema.host_cache\G
*************************** 1. row ***************************
                                        IP: 10.0.2.2
                                      HOST: _gateway
                            HOST_VALIDATED: YES
                        SUM_CONNECT_ERRORS: 0
                 COUNT_HOST_BLOCKED_ERRORS: 0
           COUNT_NAMEINFO_TRANSIENT_ERRORS: 0
           COUNT_NAMEINFO_PERMANENT_ERRORS: 0
                       COUNT_FORMAT_ERRORS: 0
           COUNT_ADDRINFO_TRANSIENT_ERRORS: 0
           COUNT_ADDRINFO_PERMANENT_ERRORS: 0
                       COUNT_FCRDNS_ERRORS: 0
                     COUNT_HOST_ACL_ERRORS: 0
               COUNT_NO_AUTH_PLUGIN_ERRORS: 0
                  COUNT_AUTH_PLUGIN_ERRORS: 0
                    COUNT_HANDSHAKE_ERRORS: 0
                   COUNT_PROXY_USER_ERRORS: 0
               COUNT_PROXY_USER_ACL_ERRORS: 0
               COUNT_AUTHENTICATION_ERRORS: 0
                          COUNT_SSL_ERRORS: 0
         COUNT_MAX_USER_CONNECTIONS_ERRORS: 0
COUNT_MAX_USER_CONNECTIONS_PER_HOUR_ERRORS: 0
             COUNT_DEFAULT_DATABASE_ERRORS: 0
                 COUNT_INIT_CONNECT_ERRORS: 0
                        COUNT_LOCAL_ERRORS: 0
                      COUNT_UNKNOWN_ERRORS: 0
                                FIRST_SEEN: 2020-12-07 15:30:19
                                 LAST_SEEN: 2020-12-07 15:30:56
                          FIRST_ERROR_SEEN: NULL
                           LAST_ERROR_SEEN: NULL
1 row in set (0.00 sec)
```

ex. Rails側の設定
```diff
# config/database.yml
@@ -6,7 +6,7 @@ development: &development
-  username: <%= ENV['DB_USERNAME']||'mysql' %>
+  username: <%= ENV['DB_USERNAME']||'myuser' %>
-  password: <%= ENV['DB_PASSWORD']||'root' %>
+  password: <%= ENV['DB_PASSWORD']||'mypassword' %>
   host:     <%= ENV['DB_HOSTNAME']||'127.0.0.1' %>
-  port:     <%= ENV['DB_PORT']||'3306' %>
+  port:     <%= ENV['DB_PORT']||'33060' %>
```

