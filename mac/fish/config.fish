# macOS fish config

if status is-interactive
    # Homebrew lives in /opt/homebrew on Apple Silicon and /usr/local on Intel Macs.
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    else if test -x /usr/local/bin/brew
        /usr/local/bin/brew shellenv | source
    end

    # Editors
    set -gx EDITOR vim
    if type -q code
        set -gx VISUAL code --wait
    else
        set -gx VISUAL $EDITOR
    end
end

function fish_greeting
    if type -q neofetch
        neofetch
    end
end
