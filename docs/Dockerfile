FROM node:22-alpine AS build

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

# The reference pages are generated with Godot (`pnpm generate`) and committed, so only build here.
RUN pnpm run build

FROM httpd:2.4

COPY --from=build /app/.vitepress/dist /usr/local/apache2/htdocs/

EXPOSE 80
