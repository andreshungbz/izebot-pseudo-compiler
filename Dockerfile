FROM openjdk:26-rc-trixie

# Install curl, jq, unzip
RUN apt-get update && apt-get install -y curl jq unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Fetch latest release info from GitHub
# Grab the URL of the assets matching our zip names
RUN bash -c 'LATEST_JSON=$(curl -s https://api.github.com/repos/andreshungbz/izebot-pseudo-compiler/releases); \
             IZEZIP_URL=$(echo "$LATEST_JSON" | jq -r '\''.[0].assets[] | select(.name=="izebot-pseudo-compiler.zip") | .browser_download_url'\''); \
             RUNTIME_URL=$(echo "$LATEST_JSON" | jq -r '\''.[0].assets[] | select(.name=="runtime.zip") | .browser_download_url'\''); \
             curl -L "$IZEZIP_URL" -o izebot-pseudo-compiler.zip; \
             curl -L "$RUNTIME_URL" -o runtime.zip'

# Unzip both archives
RUN unzip izebot-pseudo-compiler.zip && rm izebot-pseudo-compiler.zip
RUN unzip runtime.zip && rm runtime.zip

# Run the main class with runtime jars
CMD ["java", "-cp", ".:guava.jar:xtend.jar:xtext-xbase.jar:xtend-macro.jar", "main.App"]