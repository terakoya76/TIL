# repmgr

Sample: https://github.com/bitnami/bitnami-docker-postgresql-repmgr

## Term
https://repmgr.org/docs/current/overview.html

### Concept
replication cluster
* In the repmgr documentation, "replication cluster" refers to the network of PostgreSQL servers connected by streaming replication.

node
* A node is a single PostgreSQL server within a replication cluster.

upstream node
* The node a standby server connects to, in order to receive streaming replication. This is either the primary server, or in the case of cascading replication, another standby.

failover
* This is the action which occurs if a primary server fails and a suitable standby is promoted as the new primary. The repmgrd daemon supports automatic failover to minimise downtime.

switchover
* In certain circumstances, such as hardware or operating system maintenance, it's necessary to take a primary server offline; in this case a controlled switchover is necessary, whereby a suitable standby is promoted and the existing primary removed from the replication cluster in a controlled manner. The repmgr command line client provides this functionality.

fencing
* In a failover situation, following the promotion of a new standby, it's essential that the previous primary does not unexpectedly come back on line, which would result in a split-brain situation. To prevent this, the failed primary should be isolated from applications, i.e. "fenced off".

witness server
* repmgr provides functionality to set up a so-called "witness server" to assist in determining a new primary server in a failover situation with more than one standby. The witness server itself is not part of the replication cluster, although it does contain a copy of the repmgr metadata schema.
* The purpose of a witness server is to provide a "casting vote" where servers in the replication cluster are split over more than one location. In the event of a loss of connectivity between locations, the presence or absence of the witness server will decide whether a server at that location is promoted to primary; this is to prevent a "split-brain" situation where an isolated location interprets a network outage as a failure of the (remote) primary and promotes a (local) standby.
* A witness server only needs to be created if repmgrd is in use.

### Component
repmgr
* A command-line tool used to perform administrative tasks such as:
  * setting up standby servers
  * promoting a standby server to primary
  * switching over primary and standby servers
  * displaying the status of servers in the replication cluster

repmgrd
* A daemon which actively monitors servers in a replication cluster and performs the following tasks:
  * monitoring and recording replication performance
  * performing failover by detecting failure of the primary and promoting the most suitable standby server
  * provide notifications about events in the cluster to a user-defined script which can perform tasks such as sending alerts by email

## Compatiability
https://repmgr.org/docs/current/install-requirements.html#INSTALL-COMPATIBILITY-MATRIX

| repmgr | version | Supported? | Latest release     | Supported PostgreSQL versions     |
|--------|---------|------------|--------------------|-----------------------------------|
| repmgr | 5.3     | YES        | 5.3.1 (2022-02-15) | 9.4, 9.5, 9.6, 10, 11, 12, 13, 14 |
| repmgr | 5.2     | NO         | 5.2.1 (2020-12-07) | 9.4, 9.5, 9.6, 10, 11, 12, 13     |
| repmgr | 5.1     | NO         | 5.1.0 (2020-04-13) | 9.3, 9.4, 9.5, 9.6, 10, 11, 12    |
| repmgr | 5.0     | NO         | 5.0 (2019-10-15)   | 9.3, 9.4, 9.5, 9.6, 10, 11, 12    |
| repmgr | 4.x     | NO         | 4.4 (2019-06-27)   | 9.3, 9.4, 9.5, 9.6, 10, 11        |
| repmgr | 3.x     | NO         | 3.3.2 (2017-05-30) | 9.3, 9.4, 9.5, 9.6                |
| repmgr | 2.x     | NO         | 2.0.3 (2015-04-16) | 9.0, 9.1, 9.2, 9.3, 9.4           |

## Operation
Manual Promote (When Old Primary has failed)
* https://repmgr.org/docs/current/promoting-standby.html

Manual Switchover (Old Primary must be Standby)
* https://repmgr.org/docs/current/repmgr-standby-switchover.html

Manual Node Rejoin (After Promote)
* https://repmgr.org/docs/current/repmgr-node-rejoin.html
