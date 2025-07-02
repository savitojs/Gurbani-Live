# Auto-completion function for Bash and Zsh for gurbani-live
# Now, added in script itself
# Use gurbani-live completion to generate the completion script for zsh and bash
_gurbani_live_completions() {
    local cur prev
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts=('-h' '--help' '-s' '--stop' '-t' '--status' '-i' '--install' '-u' '--update' '-v' '--version' '-q' '--quick' '-c' '--completion')

    # For Bash
    if [[ -n "$BASH_VERSION" ]]; then
        COMPREPLY=( $(compgen -W "${opts[*]}" -- "${cur}") )
        return 0
    fi

    # For Zsh
    if [[ -n "$ZSH_VERSION" ]]; then
        compadd -- "${opts[@]}"
        return 0
    fi
}

# Register the function for Bash
if [[ -n "$BASH_VERSION" ]]; then
    complete -F _gurbani_live_completions gurbani-live
fi

# Register the function for Zsh
if [[ -n "$ZSH_VERSION" ]]; then
    autoload -Uz compinit && compinit
    compdef _gurbani_live_completions gurbani-live
fi
