# Docker filerun

My [filerun](http://www.filerun.com/) install in a docker container. Inspired by [official filerun](https://github.com/filerun/docker) but added uid and gid to match internal container user with external host user.

### env variables

* uid (defaut 1000) tweak container internal user ID to mach host external ID
* gid (defaut 1000) tweak container internal group ID to mach host external ID
* MYSQL_HOSTNAME (defaut db) database hostname
* MYSQL_DATABASE (defaut filerun) database name
* MYSQL_USER (defaut filerun) database user
* MYSQL_PASSWORD (defaut filerun) database user password
* MYSQL_ROOT_PASSWORD (defaut filerun) database root password

### volumes

* /user-files store all users files. Nice to map as a host folder.


# Running

frota/filerun cannot run alone and need a docker-compose file to add database server

Install [docker](https://www.google.com/search?q=install+docker), [docker-compose](https://www.google.com/search?&q=install+docker-compose) and [docker-compose-for-humans](https://github.com/neyfrota/docker-compose-for-humans) then create a docker-compose.yml file like this.

```
version: '2'
services:
    db:
        image: mariadb:10.1
        environment:
        - MYSQL_USER=filerun
        - MYSQL_PASSWORD=filerun
        - MYSQL_DATABASE=filerun
        - MYSQL_ROOT_PASSWORD=filerun
    filerun:
        build: neyfrota/filerun
        ports:
        - 0.0.0.0:80:80
        - 0.0.0.0:443:443
        volumes:
        - /tmp/path-to-store-users-folders:/user-files
        environment:
        - uid=1000
        - gid=1000
        - MYSQL_HOSTNAME=db
        - MYSQL_DATABASE=filerun
        - MYSQL_USER=filerun
        - MYSQL_PASSWORD=filerun
        - MYSQL_ROOT_PASSWORD=filerun
```

run `docker-compose-for-humans start` then access http://127.0.0.1


# Build

(todo)
