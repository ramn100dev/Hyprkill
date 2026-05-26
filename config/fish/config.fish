if status is-interactive
    # Commands to run in interactive sessions can go here
end
set -gx LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
set -gx PATH "$HOME/.npm-global/bin" $PATH
