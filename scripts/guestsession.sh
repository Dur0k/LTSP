#!/bin/bash -x
### Create and config guest accounts.

guest="guest"
pass="guest"
hostname="guest"

# create the template/skeleton guest account
groupadd guest --gid=500 -f
adduser $guest --uid=500 --gid=500 \
        --shell=/bin/bash --gecos '' \
        --disabled-password
usermod $guest --password="$(openssl passwd -stdin <<< $pass)"
chown $guest:guest -R /home/$guest

# create the guest accounts
rm -rf /home/guest-accounts/
mkdir -p /home/guest-accounts/
for ip in {1..255}; do
    user="${hostname}${ip}"
    adduser $user --uid=$((500 + $ip)) --gid=500 \
            --home=/home/guest-accounts/$user \
            --shell=/bin/bash --gecos '' \
            --disabled-password
    usermod $user --password="$(openssl passwd -stdin <<< $user)"
done

