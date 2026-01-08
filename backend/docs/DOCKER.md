# Docker Setup Documentation

This document explains the Docker configuration for the .NET 8 Web API application.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Build Process                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────┐      ┌─────────────────────┐       │
│  │   Stage 1: Build    │      │   Stage 2: Runtime  │       │
│  │   sdk:8.0-alpine    │ ───▶ │   aspnet:8.0-alpine │       │
│  │                     │      │                     │       │
│  │  • dotnet restore   │      │  • Copy publish/    │       │
│  │  • dotnet publish   │      │  • Port 8080        │       │
│  └─────────────────────┘      └─────────────────────┘       │
│        ~946MB                       ~169MB                  │
└─────────────────────────────────────────────────────────────┘
```

## Why Multi-Stage Build?

| Stage | Image | Size | Purpose |
|-------|-------|------|---------|
| Build | `sdk:8.0-alpine` | ~500MB | Contains compiler, NuGet, build tools |
| Runtime | `aspnet:8.0-alpine` | ~100MB | Contains only ASP.NET Core runtime |

The final image only contains the runtime and your app (~100MB vs ~500MB).

## Key Dockerfile Decisions

### 1. Alpine Images
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
```
Alpine Linux is ~5MB vs ~80MB for Debian-based images.

### 2. Layer Caching
```dockerfile
COPY *.csproj ./
RUN dotnet restore
COPY . .
```
Dependencies are restored before copying source, so they're cached unless `*.csproj` changes.

### 3. Port 8080
```dockerfile
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
```
.NET 8 defaults to port 8080 for non-root users (security best practice).

## Commands Reference

| Action | Command |
|--------|---------|
| Build image | `docker build -t dotnet-app .` |
| Run container | `docker run -d -p 8080:8080 dotnet-app` |
| View logs | `docker logs <container-id>` |
| Check size | `docker images dotnet-app` |
