# Command

## mongosh

### Install
https://www.mongodb.com/docs/mongodb-shell/install/#std-label-mdb-shell-install

```bash
$ sudo apt-get install gnupg
$ wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

$ echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
$ sudo apt update
$ sudo apt install -y mongodb-mongosh
```

### CLI
https://www.mongodb.com/docs/mongodb-shell/reference/methods/

connect
```bash
$ sudo mongo --host 127.0.0.1 -u root -p root
> show dbs
admin   0.000GB
config  0.000GB
hoge    0.000GB
local   0.000GB
```

Database
```bash
# create
> use <database_name>;

# drop
> db.dropDatabase();
```

Collection
```bash
# create
> db.createCollection('<collection_name>');

# drop
> db.<collection_name>.drop();

# list
> show collections;
documents

# insert
> db.documents.insertOne({title: "hoge"})

# query
> db.<collection_name>.find()
{ "_id" : ObjectId("62847e9a279bb4c4200ade18"), "created_at" : ISODate("2022-05-18T05:05:30.570Z"), "updated_at" : ISODate("2022-05-18T05:05:30.570Z"), "title" : "hoge", "content" : "hoge" }

> db.documents.find({"_id": ObjectId("62847e9a279bb4c4200ade18")})
```

