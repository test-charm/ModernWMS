FROM mcr.microsoft.com/dotnet/sdk:8.0

ENV PATH="${PATH}:/root/.dotnet/tools" \
    DOTNET_ROLL_FORWARD=Major

RUN apt-get update \
    && apt-get install -y --no-install-recommends libxml2 procps \
    && rm -rf /var/lib/apt/lists/*

RUN dotnet tool install --tool-path /root/.dotnet/tools dotnet-coverage --version 17.14.2 \
    && dotnet tool install --tool-path /root/.dotnet/tools dotnet-reportgenerator-globaltool --version 5.5.10

COPY docker/backend/run-with-coverage.sh /usr/local/bin/run-with-coverage.sh
RUN chmod +x /usr/local/bin/run-with-coverage.sh

WORKDIR /workspace/backend

EXPOSE 5555

ENTRYPOINT ["/usr/local/bin/run-with-coverage.sh"]
