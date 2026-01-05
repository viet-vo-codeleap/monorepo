# Deploy .NET App

A sample .NET 8 Web API application with Docker support, demonstrating CI/CD best practices.

## Prerequisites

- .NET 8 SDK
- Docker (for containerized deployment)

## Quick Start

### Development (dotnet CLI)

```bash
# Restore dependencies
dotnet restore

# Run the application
dotnet run
```

Open [http://localhost:5000/weatherforecast](http://localhost:5000/weatherforecast) in your browser.

### Production (Docker)

```bash
# Build Docker image
docker build -t dotnet-app .

# Run container
docker run -d -p 8080:8080 --name dotnet-app dotnet-app
```

Open [http://localhost:8080/weatherforecast](http://localhost:8080/weatherforecast) in your browser.

### Stop Container

```bash
docker stop dotnet-app && docker rm dotnet-app
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/weatherforecast` | GET | Returns 5-day weather forecast |
| `/swagger` | GET | API documentation (dev only) |

## Project Structure

```
├── Program.cs              # Application entry point
├── DeployDotnetApp.csproj  # Project configuration
├── Properties/             # Launch settings
├── Dockerfile             # Multi-stage Docker build
├── .dockerignore          # Docker build exclusions
└── appsettings.json       # Application configurations
```

## Docker Best Practices Applied

- **Multi-stage build**: Build with SDK, run with runtime-only image
- **Alpine images**: `sdk:8.0-alpine` and `aspnet:8.0-alpine` for minimal size
- **Layer caching**: `.csproj` copied before source for dependency caching
- **Non-root user**: ASP.NET Core runs as non-root by default
- **Production ready**: Environment set to Production

## Available Commands

| Command | Description |
|---------|-------------|
| `dotnet run` | Run development server |
| `dotnet build` | Build the application |
| `dotnet publish` | Create production build |
| `dotnet test` | Run unit tests |

## License

MIT
