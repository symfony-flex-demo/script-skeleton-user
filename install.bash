#!/bin/sh
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

origin=$(pwd)
composer create-project --no-install symfony/$PACKAGE $CREATE_PROJECT_DIRECTORY
if [[ -v $CREATE_PROJECT_DIRECTORY ]]; then
  cd $CREATE_PROJECT_DIRECTORY
else
  cd $PACKAGE
fi
pwd
(cd $origin/etap/install && tar --exclude-vcs --create --file - .) | tar --extract --verbose --file -
composer config bin-dir bin
# cp $origin/.env.dist . # Needs apparently to be done before install.

composer install
# composer require symfony/yaml # in symfony/skeleton
# composer require symfony/console # in symfony/skeleton
composer require twig # symfony/twig-bundle # in symfony/website-skeleton
composer require annotations # sensio/framework-extra-bundle # in symfony/website-skeleton
composer require orm-pack # symfony/orm-pack # in symfony/website-skeleton
composer require mailer # symfony/swiftmailer-bundle # in symfony/website-skeleton
# composer require symfony/security-csrf
# cp $origin/config/packages/*.yaml config/packages --verbose
# cp $origin/config/routes/*.yaml config/routes --verbose
(cd $origin/etap/fos_user && tar --exclude-vcs --create --file - .) | tar --extract --verbose --file -
composer require friendsofsymfony/user-bundle
composer require web-server # symfony/web-server-bundle
composer require browser-kit # symfony/browser-kit
composer require simple-phpunit # symfony/phpunit-bridge

# cp $origin/src/Entity/*.php src/Entity --verbose # May be done earlier.
bin/console doctrine:database:create
bin/console doctrine:migrations:diff --quiet
bin/console doctrine:migrations:migrate --no-interaction --quiet
# bin/console doctrine:schema:update --force
# composer require doctrine/doctrine-fixtures-bundle --dev
# cp $origin/src/DataFixtures/AppFixtures.php src/DataFixtures
# bin/console doctrine:fixtures:load --append
bin/console fos:user:create superadmin superadmin@example.com superadmin --super-admin
bin/console fos:user:create user user@example.com user

bin/console assets:install --symlink
