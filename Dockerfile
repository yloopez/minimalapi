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

# Copy from the build stage
COPY --from=build /out .

# Open port (optional but good for documentation)
EXPOSE 80

# # Add health check
# HEALTHCHECK --interval=5s --timeout=3s --start-period=3s --retries=5 \
#   CMD curl --fail http://localhost:80/ || exit 1

# Set the startup command
ENTRYPOINT ["dotnet", "SixMinApi.dll"]
