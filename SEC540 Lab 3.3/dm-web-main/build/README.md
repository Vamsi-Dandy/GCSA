# Prerequisite Containers

Start redis cluster:

```
docker run -d -p 6379:6379 redis
```

Start the DM API container:

```
docker build -t sans:dm-api:stable
docker run -d -p 8080:8888 sans/dm-api:stable
```

You should be able to browse to [http://127.0.0.1:8080/api/user](http://127.0.0.1:8080/api/user) and see some JSON

# Configuration

Modify the `application.properties` file and set the API endpoint. Change the value to:

```
dundermifflin.service.url=http://127.0.0.1:8080/api
```

Modify the `application.properties` file and set the redis host:

```
spring.redis.host=127.0.0.1
```

# Build Commands

```bash
# Build the app
mvn install

# Run the app
mvn spring-boot:run
```

Browse to the site at [https://127.0.0.1:8443/home](https://127.0.0.1:8443/home).
