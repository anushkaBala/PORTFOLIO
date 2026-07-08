FROM node:20-alpine AS base
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json ./
ENV HTTP_PROXY=http://172.23.0.4:2003
ENV HTTPS_PROXY=http://172.23.0.4:2003
ENV http_proxy=http://172.23.0.4:2003
ENV https_proxy=http://172.23.0.4:2003
RUN npm config set registry https://npm.mirrors.msh.team \
    && npm config set proxy $HTTP_PROXY \
    && npm config set https-proxy $HTTPS_PROXY \
    && npm config set strict-ssl false \
    && npm config set fund false \
    && npm config set audit false
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline --no-audit

FROM deps AS build
COPY . .
RUN npm run build

FROM node:20-alpine AS production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json .env ./






















































- name: Configure git
    run: |
      git config user.name "${{ github.actor }}"
      git config user.email "${{ github.actor }}@users.noreply.github.com"

  - name: Create backdated commits
    env:
      YEAR: '2026'
      TZ: '+00:00'
      FILE: 'date-commits.txt'
    run: |
      set -euo pipefail
      BRANCH="backdated-commits-2026"
      YEAR=${YEAR}
      TZ=${TZ}
      FILE=${FILE}

      echo "Running on branch: $(git rev-parse --abbrev-ref HEAD)"

      # Ensure we're on the correct branch (create it if checkout didn't)
      if [ "$(git rev-parse --abbrev-ref HEAD)" != "$BRANCH" ]; then
        git checkout -b "$BRANCH"
      fi

      commit_at() {
        ts="$1"   # e.g. 2026-01-05T12:00:00+00:00
        echo "Backdated commit at $ts by $GITHUB_ACTOR" >> "$FILE"
        git add "$FILE"
        GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" git commit -m "Backdate: $ts"
      }

      # 1) Jan 1-20
      for d in $(seq -w 1 20); do
        commit_at "${YEAR}-01-${d}T12:00:00${TZ}"
      done

      # 2) Feb 1-20
      for d in $(seq -w 1 20); do
        commit_at "${YEAR}-02-${d}T12:00:00${TZ}"
      done

      # 3) Mar 12-22
      for d in $(seq -w 12 22); do
        commit_at "${YEAR}-03-${d}T12:00:00${TZ}"
      done

      # 4) Apr 23-29
      for d in $(seq -w 23 29); do
        commit_at "${YEAR}-04-${d}T12:00:00${TZ}"
      done

      # 5) May 1-31, 7 commits/day (use different times within day)
      for day in $(seq -w 1 31); do
        for hour in 09 10 11 12 13 14 15; do
          commit_at "${YEAR}-05-${day}T${hour}:00:00${TZ}"
        done
      done

      # 6) Jun 1-30, 7 commits/day
      for day in $(seq -w 1 30); do
        for hour in 09 10 11 12 13 14 15; do
          commit_at "${YEAR}-06-${day}T${hour}:00:00${TZ}"
        done
      done

      # Push the new branch back to origin
      git push --set-upstream origin "$BRANCH"

EXPOSE 3000
CMD ["npm", "start"]
