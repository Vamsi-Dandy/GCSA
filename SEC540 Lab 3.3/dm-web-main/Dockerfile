FROM maven:3.9.4-amazoncorretto-8 as build
WORKDIR /app
COPY . .

RUN mvn --batch-mode package && \
    mv target/*.jar app.jar

FROM amazoncorretto:8-alpine3.18

ARG SPRING_PROFILE=aws
ARG PORT=8443
ENV PORT=$PORT

USER root

WORKDIR /app
COPY --from=build /app/app.jar ./

RUN echo $SPRING_PROFILE > spring_profile.conf

CMD java -Dspring.profiles.active=$(cat spring_profile.conf) -jar app.jar --server.port=$PORT
