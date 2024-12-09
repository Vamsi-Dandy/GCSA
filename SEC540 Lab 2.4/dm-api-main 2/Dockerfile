FROM maven:3.9.4-amazoncorretto-20 as build
WORKDIR /app
COPY . .

# build the application into a single JAR, including dependencies
RUN mvn --batch-mode package && \
    mv target/*.jar app.jar

FROM amazoncorretto:20.0.2-alpine3.18
ENV PORT=8888

WORKDIR /app
COPY --from=build /app/app.jar ./

RUN addgroup -S app && adduser -S app -G app
USER app

CMD java -jar app.jar --server.port=$PORT
