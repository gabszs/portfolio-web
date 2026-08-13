# Base stage for building the static files
FROM node:24 AS base
WORKDIR /app

# Install pnpm — versao fixa de proposito.
# `pnpm@latest` passou a resolver 11.x, que trata build script ignorado como
# erro fatal (ERR_PNPM_IGNORED_BUILDS: esbuild, sharp) e quebra o install.
RUN corepack enable && corepack prepare pnpm@10.10.0 --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

# Runtime stage for serving the application
FROM nginx:mainline-alpine-slim AS runtime
COPY --from=base /app/dist /usr/share/nginx/html
EXPOSE 80
