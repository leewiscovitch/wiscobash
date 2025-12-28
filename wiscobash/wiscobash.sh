#configure .bashrc
for bashrc_file in ~/.bashrc; do
    if ! grep -qF 'source ~/wiscobash/wiscobash.sh' $bashrc_file; then
        echo "" >> $bashrc_file
        echo "#wiscobash.sh" >> $bashrc_file
        echo "source ~/wiscobash/wiscobash.sh" >> $bashrc_file
    fi
done

if [ -d ~/wiscobash/scripts/applications/ ]; then
    for wiscobash_file in ~/wiscobash/scripts/applications/*.sh; do
    if [ -f "$wiscobash_file" ]; then
        . "$wiscobash_file"
    fi
    done
fi

if [ -d ~/wiscobash/scripts/aliases/ ]; then
    for wiscobash_file in ~/wiscobash/scripts/aliases/*.sh; do
    if [ -f "$wiscobash_file" ]; then
        . "$wiscobash_file"
    fi
    done
fi

if [ -d ~/wiscobash/scripts/functions/ ]; then
    for wiscobash_file in ~/wiscobash/scripts/functions/*.sh; do
    if [ -f "$wiscobash_file" ]; then
        . "$wiscobash_file"
    fi
    done
fi

#add folders to path
export PATH="/home/tech/wiscobash/bin:$PATH"
##set system context
export LIBVIRT_DEFAULT_URI="qemu:///system"