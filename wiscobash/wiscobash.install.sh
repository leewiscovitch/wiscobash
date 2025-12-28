#configure .bashrc
for bashrc_file in ~/.bashrc; do
    if ! grep -qF 'source ~/wiscobash/wiscobash.sh' $bashrc_file; then
        echo "" >> $bashrc_file
        echo "#wiscobash.sh" >> $bashrc_file
        echo "source ~/wiscobash/wiscobash.sh" >> $bashrc_file
    fi
done