__conda_setup="$('/home/tech/wiscobash/opt/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/tech/wiscobash/opt/miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/tech/wiscobash/opt/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/tech/wiscobash/opt/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
export CONDARC=~/wiscobash/etc/condarc
conda deactivate