# docker-pgpool
A Pgpool-II docker image base on alpine linux.

## Usage
```bash
$ docker run -d --name pgpool \
         --env PGPOOL_BACKENDS=pg1:5432:5,pg2:5432:5,pg3:5432:5 \
         0xff/pgpool
```
