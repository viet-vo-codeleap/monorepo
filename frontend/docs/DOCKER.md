# Docker Setup Documentation

This document explains the Docker configuration and best practices applied in this Angular 19 project.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Build Process                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────┐      ┌─────────────────────┐       │
│  │   Stage 1: Build    │      │   Stage 2: Serve    │       │
│  │   node:22-alpine    │ ───▶ │   nginx:alpine      │       │
│  │                     │      │                     │       │
│  │  • npm ci           │      │  • Copy dist/       │       │
│  │  • npm run build    │      │  • nginx.conf       │       │
│  │  • Output: dist/    │      │  • Port 80          │       │
│  └─────────────────────┘      └─────────────────────┘       │
│        ~1.2GB                        ~81MB                  │
└─────────────────────────────────────────────────────────────┘
```

## File Breakdown

### Dockerfile

```dockerfile
# Stage 1: Build environment
FROM node:22-alpine AS build
# Uses Alpine Linux (~50MB vs ~1GB for full node image)

WORKDIR /app
COPY package*.json ./     # Copy package files first for layer caching
RUN npm ci                 # Clean install (faster, deterministic)
COPY . .                   # Copy source after dependencies
RUN npm run build          # Build production bundle

# Stage 2: Production server
FROM nginx:alpine
# Final image only contains nginx + built assets (~81MB total)
```

**Why Multi-Stage?**
- Build dependencies (node_modules, TypeScript, etc.) are discarded
- Final image contains only static files + nginx
- Reduces attack surface and image size

---

### nginx.conf

| Configuration | Purpose |
|--------------|---------|
| `try_files $uri $uri/ /index.html` | SPA routing - serves index.html for all routes |
| `gzip on` | Compresses responses (60-80% size reduction) |
| `expires 1y` on assets | Browser caching for hashed files |
| `X-Frame-Options` | Prevents clickjacking attacks |
| `X-Content-Type-Options` | Prevents MIME sniffing |

**SPA Routing Explained:**
```
User navigates to: /dashboard
                      │
                      ▼
              Nginx receives request
                      │
        ┌─────────────┴─────────────┐
        │ try_files $uri $uri/      │
        │ /index.html               │
        └─────────────┬─────────────┘
                      │
    1. Check if /dashboard file exists → NO
    2. Check if /dashboard/ dir exists → NO
    3. Fallback to /index.html        → YES ✓
                      │
                      ▼
         Angular Router handles /dashboard
```

---

### .dockerignore

Excludes from build context:
- `node_modules/` - Reinstalled in container
- `.git/` - Not needed for build
- `*.spec.ts` - Test files not needed in production
- `*.md` - Documentation files

**Impact:** Faster builds, smaller context sent to Docker daemon.

---

## Commands Reference

| Action | Command |
|--------|---------|
| Dev server | `npm start` → http://localhost:4200 |
| Build | `docker build -t angular-app .` |
| Run container | `docker run -d -p 8080:80 angular-app` |
| Stop container | `docker stop <id> && docker rm <id>` |
| View logs | `docker logs <container-id>` |
| Check image size | `docker images angular-app` |

## Image Size Comparison

| Approach | Size |
|----------|------|
| `node:22` (full) | ~1.1 GB |
| `node:22-alpine` + `nginx:alpine` (multi-stage) | **~81 MB** |

The multi-stage approach reduces image size by **93%**.
