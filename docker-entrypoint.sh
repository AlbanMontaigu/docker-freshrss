#!/bin/bash
set -e

# Who and where am I ?
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] GLOBAL INFORMATIONS"
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] whoami : $(whoami)"
echo >&2 "[INFO] pwd : $(pwd)"

# Backup the prev install in case of fail...
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Backup old freshrss installation in $(pwd)"
echo >&2 "[INFO] ---------------------------------------------------------------"
tar -zcvf /var/backup/freshrss/freshrss-v$(date '+%Y%m%d%H%M%S').tar.gz .
echo >&2 "[INFO] Complete! Backup successfully done in $(pwd)"

# Since freshrss can be upgraded by overwriting files do the upgrade !
# @TODO use VERSION file to check if necessary
# @see https://github.com/FreshRSS/FreshRSS#example-of-full-installation-on-linux-debianubuntu
# 
# File copy strategy taken from wordpress entrypoint
# @see https://github.com/docker-library/wordpress/blob/master/fpm/docker-entrypoint.sh
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Installing or upgrading freshrss in $(pwd) - copying now..."
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Removing old installation"
find -maxdepth 1 ! -regex '^\./data.*$' ! -regex '^\.$' -exec rm -rvf {} +
echo >&2 "[INFO] Extracting new installation"
tar cvf - --one-file-system -C /usr/src/freshrss . | tar xvf -
echo >&2 "[INFO] Fixing rights"
chown -Rfv nginx:nginx .
echo >&2 "[INFO] Complete! FreshRSS has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
