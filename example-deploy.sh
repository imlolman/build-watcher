if [ -z "$1" ]; then
  echo "Usage: $0 <user>"
  exit 1
fi

DEPLOY_USER="$1"


REPO=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} | awk -F'/' '{print $1}')
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git pull "$REPO" "$BRANCH"
composer install --no-dev --optimize-autoloader
bun install
bun run build
php artisan filament:assets
php artisan migrate --force
php artisan optimize:clear
php artisan optimize
git checkout package-lock.json
git checkout bun.lock
chown -R $DEPLOY_USER:$DEPLOY_USER .
chown $DEPLOY_USER:nogroup .
service supervisor restart