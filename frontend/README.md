# Deploy Angular App

A sample Angular 19 application with Docker support, demonstrating CI/CD best practices.

## Prerequisites

- Node.js 22+
- npm 10+
- Docker (for containerized deployment)

## Quick Start

### Development (npm)

```bash
# Install dependencies
npm install

# Start development server
npm start
```

Open [http://localhost:4200](http://localhost:4200) in your browser.

### Production (Docker)

```bash
# Build Docker image
docker build -t angular-app .

# Run container
docker run -d -p 8080:80 --name angular-app angular-app
```

Open [http://localhost:8080](http://localhost:8080) in your browser.

### Stop Container

```bash
docker stop angular-app && docker rm angular-app
```

## Project Structure

```
├── src/                    # Application source code
│   ├── app/               # Angular components
│   └── index.html         # Entry HTML
├── Dockerfile             # Multi-stage Docker build
├── nginx.conf             # Nginx configuration for SPA
├── .dockerignore          # Docker build exclusions
└── angular.json           # Angular CLI configuration
```

## Docker Best Practices Applied

- **Multi-stage build**: Separates build and runtime environments
- **Alpine images**: Uses `node:22-alpine` and `nginx:alpine` for minimal size
- **Layer caching**: Copies `package*.json` before source for better caching
- **Security headers**: Nginx configured with XSS, MIME sniffing protections
- **Gzip compression**: Enabled for text-based assets
- **SPA routing**: Fallback to `index.html` for Angular Router

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start development server |
| `npm run build` | Build production bundle |
| `npm test` | Run unit tests |
| `npm run watch` | Build in watch mode |

## License

MIT
