FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app
COPY Benchmarks .
RUN dotnet publish -c Release -o out
COPY Benchmarks/appsettings.postgresql.json ./out/appsettings.json

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
ENV ASPNETCORE_URLS http://+:8080
WORKDIR /app
COPY --from=build /app/out ./

EXPOSE 8080

# Start Contrast Additions
RUN apt-get update && apt-get install unzip

COPY Contrast.NET.Core.zip Contrast.NET.Core.zip
COPY contrast_security.yaml /etc/contrast/contrast_security.yaml

ENV CONTRAST__ASSESS__ENABLE=true
ENV CONTRAST__PROTECT__ENABLE=true

ENV CORECLR_PROFILER_PATH_64="/app/Contrast.NET.Core/runtimes/linux-x64/native/ContrastProfiler.so"
ENV CORECLR_PROFILER="{8B2CE134-0948-48CA-A4B2-80DDAD9F5791}"
ENV CORECLR_ENABLE_PROFILING=1
ENV CONTRAST_CONFIG_PATH=/etc/contrast/contrast_security.yaml

RUN unzip Contrast.NET.Core.zip -d Contrast.NET.Core
# End Contrast Additions

ENTRYPOINT ["dotnet", "Benchmarks.dll"]