FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

WORKDIR /src

COPY backend/ModernWMS.sln backend/
COPY backend/ModernWMS/ModernWMS.csproj backend/ModernWMS/
COPY backend/ModernWMS.Core/ModernWMS.Core.csproj backend/ModernWMS.Core/
COPY backend/ModernWMS.WMS/ModernWMS.WMS.csproj backend/ModernWMS.WMS/

RUN dotnet restore backend/ModernWMS.sln

COPY backend/ backend/

WORKDIR /src/backend/ModernWMS
RUN dotnet publish ModernWMS.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final

WORKDIR /app

COPY --from=build /app/publish ./

EXPOSE 5555

ENTRYPOINT ["dotnet", "ModernWMS.dll"]
