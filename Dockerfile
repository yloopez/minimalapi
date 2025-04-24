# ---------- STAGE 1: Build ----------
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o /out

# ---------- STAGE 2: Runtime ----------
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app

# Install curl (new)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy from the build stage
COPY --from=build /out .

# Open port (optional but good for documentation)
EXPOSE 80

# Set the startup command
ENTRYPOINT ["dotnet", "SixMinApi.dll"]
