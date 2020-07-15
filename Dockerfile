FROM kshivaprasad/java
RUN apt-get update
RUN apt-get upgrade --fix-missing -y
RUN apt-get install -y curl
RUN apt-get install -y p7zip \
    p7zip-full \
    unace \
    zip \
    unzip

# Copy the fat jar file.
COPY target/SeleniumDocker-1.0-SNAPSHOT-fat-tests.jar app/SeleniumDocker-1.0-SNAPSHOT-fat-tests.jar
#COPY --from=build /app/target/SeleniumDocker-1.0-SNAPSHOT-fat-tests.jar /app/SeleniumDocker-1.0-SNAPSHOT-fat-tests.jar

# Install Chrome for Selenium
RUN curl http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_83.0.4103.116-1_amd64.deb -o /chrome.deb
#COPY chrome.deb /
RUN dpkg -i /chrome.deb || apt-get install -yf
RUN rm /chrome.deb

# Install chromedriver for Selenium
RUN mkdir -p /app/bin
RUN curl https://chromedriver.storage.googleapis.com/83.0.4103.39/chromedriver_linux64.zip -o /tmp/chromedriver.zip \
    && unzip /tmp/chromedriver.zip -d /app/bin/ \
    && rm /tmp/chromedriver.zip
#COPY chromedriver /app/bin/chromedriver

ARG MAVEN_VERSION=3.6.3

# 2- Define a constant with the working directory
ARG USER_HOME_DIR="/root"

# 3- Define the SHA key to validate the maven download
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0

# 4- Define the URL where maven can be downloaded from
ARG BASE_URL=http://apachemirror.wuchna.com/maven/maven-3/${MAVEN_VERSION}/binaries

# 5- Create the directories, download maven, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Checking download hash" \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  \
  && echo "Unziping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 6- Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

#COPY src /app/src
#COPY pom.xml /app
COPY testng /app/testng
COPY entrypoint2.sh /entrypoint2.sh
RUN chmod +x /app/bin/chromedriver
#RUN mvn -f /app/pom.xml clean package
ENTRYPOINT ["/entrypoint2.sh"]