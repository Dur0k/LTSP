#!/bin/bash -x
### Create and config guest accounts.

guest=${1:-guest}
pass=${2:-pass}
hostname=${3:-ltsp}

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

# create a script that resets a guest account
cat <<EOF > /usr/local/bin/reset-guest-account.sh
#!/bin/bash
user=\$SUDO_USER
[[ \$user =~ ^'$hostname'[0-9]{1,3}\$ ]] || exit 1
cd /home/guest-accounts/\$user || exit 2
rm -rf .* *
rsync -a /home/$guest/ .
chown \$user -R .
EOF
chmod +x /usr/local/bin/reset-guest-account.sh

# allow users of group 'guest' to call the reset script with sudo
cat <<EOF > /etc/sudoers.d/reset-guest-account
# users of group 'guest' can call the reset script without password
%guest  ALL = (root) NOPASSWD: /usr/local/bin/reset-guest-account.sh
EOF

# make sure guest accounts are reset on login
cat <<EOF > /usr/share/ldm/rc.d/S00-guest-sessions
# if username matches the pattern of a guest account
# then call the script that resets the account
echo \$LDM_USERNAME | grep -E '^$hostname[0-9]{1,3}\$' \\
    && ssh -S "\$LDM_SOCKET" "\$LDM_SERVER" 'sudo /usr/local/bin/reset-guest-account.sh'
EOF

### place some limits on guest accounts
sed -i /etc/security/limits.conf -e '/^### custom/,$ d'
cat <<EOF >> /etc/security/limits.conf
### custom
@guest        hard    nproc           1000
 *             hard    core            0
@guest        hard    cpu             2
@guest        hard    maxlogins       1
EOF