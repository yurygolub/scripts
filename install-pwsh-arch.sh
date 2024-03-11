sudo pacman --sync --refresh
sudo pacman --sync --noconfirm git

git clone https://aur.archlinux.org/powershell-bin.git
cd powershell-bin
makepkg --syncdeps
sudo pacman --upgrade --noconfirm powershell-bin-*.pkg.tar.zst
