FROM --platform=linux/amd64 eclipse-temurin:11-jre AS jre

FROM --platform=linux/amd64 apache/hadoop:3.3.6

# Flink CDC 3.7 requires Java 11+. YARN launches Flink's ApplicationMaster
# and TaskManagers inside the NodeManager container, so the whole Hadoop/YARN
# runtime must use the same JRE version.
COPY --from=jre /opt/java/openjdk /opt/java/openjdk

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=${JAVA_HOME}/bin:${PATH}
