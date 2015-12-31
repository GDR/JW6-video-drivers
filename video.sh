RED='\033[0;31m'
NC='\033[0m' # No Color

function print_message() {
  echo -e $RED[---] $1$NC
}

print_message "Script which helps to install video drivers"
if [ "$EUID" -ne 0 ]
then
  print_message "Plese run as root"
  exit
fi
print_message "Installing main drivers"
pacman -q --needed -S intel-dri xf86-video-intel  xf86-input-mouse xf86-input-synaptics xf86-input-keyboard
print_message "Installing nvidia drivers"
pacman -q --needed -S bumblebee nvidia bbswitch primus mesa-demos
print_message "Adding to group bumblebee"
gpasswd -a $(whoami) bumblebee
print_message "Addiding bumblebee at startup"
systemctl enable bumblebeed.service
print_message "Adding to black list nouveau"
echo "blacklist nouveau" > /etc/modprobe.d/modprobe.conf
print_message "Editing bumblebee.conf"
sed -i -e 's/^Driver=$/Driver=nvidia/gm' /etc/bumblebee/bumblebee.conf
sed -i -e 's/^Bridge=auto$/Bridge=virualgl/g' /etc/bumblebee/bumblebee.conf
print_message "Editing mkinitcpio.conf"
sed -i -e 's/^MODULES=\"\"$/MODULES=\"i915 bbswitch\"/gm' /etc/mkinitcpio.conf
print_message "Making initcpio"
mkinitcpio -p linux
print_message "Configuring grub"
sed -i -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"$/GRUB_CMDLINE_LINUX_DEFAULT=\"rcutree.rcu_idle_gp_delay=1\"/gm' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
print_message "Fixing xorg"
sed -i -e 's/^#   BusID \"PCI:01:00:0\"$/    BusID \"PCI:01:00:0\"/gm' /etc/bumblebee/xorg.conf.nvidia
print_message "Do you wish to reboot?"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) reboot; break;;
    No ) exit;;
  esac
done
exit

