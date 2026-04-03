# usagi-cli-banner — terminal startup banner
# Source this file from .zshrc

# --- Guard ---
[[ ! -o interactive ]] && return
[[ -p /dev/stdout ]] && return
[[ "${USAGI_DISABLE:-0}" == "1" ]] && return

() {
    # --- Resolve install directory ---
    local _usagi_install_dir="${${(%):-%x}:A:h}"

    # --- Defaults ---
    local _usagi_theme="${USAGI_THEME:-pink}"
    local _usagi_show_date=true
    local _usagi_show_host=true
    local _usagi_show_uptime=true
    local _usagi_show_shell=true
    local _usagi_show_os=true
    local _usagi_show_cpu=false
    local _usagi_show_memory=false
    local _usagi_show_quote=true
    local _usagi_separator=" ~ "
    local _usagi_art_file=""
    local _usagi_quotes_file=""

    # --- Colors (inline pink fallback) ---
    local _usagi_color_art=$'\e[38;5;199m'
    local _usagi_color_label=$'\e[38;5;218m'
    local _usagi_color_value=$'\e[38;5;255m'
    local _usagi_color_quote=$'\e[38;5;183m'
    local _usagi_color_separator=$'\e[38;5;218m'
    local _usagi_color_reset=$'\e[0m'

    # --- Source user config ---
    local _usagi_config="$HOME/.config/usagi/config.zsh"
    [[ -f "$_usagi_config" ]] && source "$_usagi_config"

    # --- Load theme ---
    local _usagi_theme_file="$_usagi_install_dir/themes/${_usagi_theme}.zsh"
    [[ -f "$_usagi_theme_file" ]] && source "$_usagi_theme_file"

    # Re-source user config so custom colors override theme
    [[ -f "$_usagi_config" ]] && source "$_usagi_config"

    # --- Gather system info ---
    local -a _usagi_info_labels _usagi_info_values

    zmodload zsh/datetime

    if [[ "$_usagi_show_date" == true ]]; then
        local _usagi_date
        strftime -s _usagi_date '%a %b %d, %Y  %H:%M' $EPOCHSECONDS
        _usagi_info_labels+=("Date")
        _usagi_info_values+=("$_usagi_date")
    fi

    if [[ "$_usagi_show_host" == true ]]; then
        _usagi_info_labels+=("Host")
        _usagi_info_values+=("$HOST")
    fi

    if [[ "$_usagi_show_uptime" == true ]]; then
        local _usagi_boot _usagi_now _usagi_up _usagi_days _usagi_hours _usagi_mins _usagi_upstr
        _usagi_boot=$(sysctl -n kern.boottime 2>/dev/null | sed 's/^.*{ sec = \([0-9]*\),.*/\1/')
        if [[ -n "$_usagi_boot" ]]; then
            _usagi_now=$EPOCHSECONDS
            (( _usagi_up = _usagi_now - _usagi_boot ))
            (( _usagi_days = _usagi_up / 86400 ))
            (( _usagi_hours = (_usagi_up % 86400) / 3600 ))
            (( _usagi_mins = (_usagi_up % 3600) / 60 ))
            _usagi_upstr=""
            (( _usagi_days > 0 )) && _usagi_upstr+="${_usagi_days}d "
            _usagi_upstr+="${_usagi_hours}h ${_usagi_mins}m"
            _usagi_info_labels+=("Uptime")
            _usagi_info_values+=("$_usagi_upstr")
        fi
    fi

    if [[ "$_usagi_show_shell" == true ]]; then
        _usagi_info_labels+=("Shell")
        _usagi_info_values+=("zsh $ZSH_VERSION")
    fi

    if [[ "$_usagi_show_os" == true ]]; then
        local _usagi_os_name _usagi_os_ver _usagi_os_arch _usagi_os
        _usagi_os_name=$(sw_vers -productName 2>/dev/null)
        _usagi_os_ver=$(sw_vers -productVersion 2>/dev/null)
        _usagi_os_arch=$(uname -m 2>/dev/null)
        if [[ -n "$_usagi_os_name" ]]; then
            _usagi_os="${_usagi_os_name} ${_usagi_os_ver}"
            [[ -n "$_usagi_os_arch" ]] && _usagi_os+=" (${_usagi_os_arch})"
            _usagi_info_labels+=("OS")
            _usagi_info_values+=("$_usagi_os")
        fi
    fi

    if [[ "$_usagi_show_cpu" == true ]]; then
        local _usagi_cpu
        _usagi_cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
        if [[ -n "$_usagi_cpu" ]]; then
            _usagi_info_labels+=("CPU")
            _usagi_info_values+=("$_usagi_cpu")
        fi
    fi

    if [[ "$_usagi_show_memory" == true ]]; then
        local _usagi_mem_bytes _usagi_mem_gb
        _usagi_mem_bytes=$(sysctl -n hw.memsize 2>/dev/null)
        if [[ -n "$_usagi_mem_bytes" ]]; then
            (( _usagi_mem_gb = _usagi_mem_bytes / 1073741824 ))
            _usagi_info_labels+=("Memory")
            _usagi_info_values+=("${_usagi_mem_gb} GB")
        fi
    fi

    # --- Select random quote ---
    local _usagi_quote=""
    if [[ "$_usagi_show_quote" == true ]]; then
        local _usagi_qfile=""
        if [[ -n "$_usagi_quotes_file" && -f "$_usagi_quotes_file" ]]; then
            _usagi_qfile="$_usagi_quotes_file"
        elif [[ -f "$HOME/.config/usagi/quotes.txt" ]]; then
            _usagi_qfile="$HOME/.config/usagi/quotes.txt"
        elif [[ -f "$_usagi_install_dir/defaults/quotes.txt" ]]; then
            _usagi_qfile="$_usagi_install_dir/defaults/quotes.txt"
        fi

        if [[ -n "$_usagi_qfile" ]]; then
            local -a _usagi_quotes
            _usagi_quotes=("${(@f)$(<"$_usagi_qfile")}")
            # Remove empty lines
            _usagi_quotes=("${(@)_usagi_quotes:#}")
            if (( ${#_usagi_quotes} > 0 )); then
                _usagi_quote="${_usagi_quotes[$(( RANDOM % ${#_usagi_quotes} + 1 ))]}"
            fi
        fi
    fi

    # --- Load ASCII art ---
    local _usagi_art=""
    local _usagi_afile=""
    if [[ -n "$_usagi_art_file" && -f "$_usagi_art_file" ]]; then
        _usagi_afile="$_usagi_art_file"
    elif [[ -f "$HOME/.config/usagi/ascii-art.txt" ]]; then
        _usagi_afile="$HOME/.config/usagi/ascii-art.txt"
    elif [[ -f "$_usagi_install_dir/defaults/ascii-art.txt" ]]; then
        _usagi_afile="$_usagi_install_dir/defaults/ascii-art.txt"
    fi

    if [[ -n "$_usagi_afile" ]]; then
        _usagi_art=$(<"$_usagi_afile")
    fi

    function usagi_render_banner() {
        local _usagi_term_width=${COLUMNS:-80}
        local -a _usagi_art_lines
        local _usagi_aline

        # Store art lines
        if [[ -n "$_usagi_art" ]]; then
            while IFS= read -r _usagi_aline; do
                _usagi_art_lines+=("$_usagi_aline")
            done <<< "$_usagi_art"
        fi

        print ""

        # Print art (always center, truncate or pad as needed)
        if [[ -n "$_usagi_art" && $_usagi_term_width -ge 5 ]]; then
            for _usagi_aline in "${_usagi_art_lines[@]}"; do
                local _line="$_usagi_aline"
                # Truncate if too long
                if (( ${#_line} > _usagi_term_width )); then
                    _line="${_line:0:$_usagi_term_width}"
                fi
                # Center if possible
                local _pad=$(( (_usagi_term_width - ${#_line}) / 2 ))
                local _padding=""
                (( _pad > 0 )) && _padding="${(l:_pad:: :)}"
                print "${_padding}${_usagi_color_art}${_line}${_usagi_color_reset}"
            done
            print ""
        fi

        # Find max label width for alignment
        local _usagi_maxlen=0
        local _usagi_l
        for _usagi_l in "${_usagi_info_labels[@]}"; do
            (( ${#_usagi_l} > _usagi_maxlen )) && _usagi_maxlen=${#_usagi_l}
        done

        # Calculate info block width for centering
        local _usagi_info_max_width=0
        local _usagi_i
        for (( _usagi_i = 1; _usagi_i <= ${#_usagi_info_labels}; _usagi_i++ )); do
            local _usagi_line_width=$(( 2 + _usagi_maxlen + ${#_usagi_separator} + ${#_usagi_info_values[$_usagi_i]} ))
            (( _usagi_line_width > _usagi_info_max_width )) && _usagi_info_max_width=$_usagi_line_width
        done

        local _usagi_info_pad=$(( (_usagi_term_width - _usagi_info_max_width) / 2 ))
        (( _usagi_info_pad < 0 )) && _usagi_info_pad=0
        local _usagi_info_padding=""
        (( _usagi_info_pad > 0 )) && _usagi_info_padding="${(l:_usagi_info_pad:: :)}"

        # Print info lines
        for (( _usagi_i = 1; _usagi_i <= ${#_usagi_info_labels}; _usagi_i++ )); do
            local _usagi_padded="${_usagi_info_labels[$_usagi_i]}"
            while (( ${#_usagi_padded} < _usagi_maxlen )); do
                _usagi_padded+=" "
            done
            print "${_usagi_info_padding}  ${_usagi_color_label}${_usagi_padded}${_usagi_color_separator}${_usagi_separator}${_usagi_color_value}${_usagi_info_values[$_usagi_i]}${_usagi_color_reset}"
        done

        # Print quote
        if [[ -n "$_usagi_quote" ]]; then
            local _usagi_quote_text="\"${_usagi_quote}\""
            local _usagi_quote_pad=$(( (_usagi_term_width - ${#_usagi_quote_text} - 2) / 2 ))
            (( _usagi_quote_pad < 0 )) && _usagi_quote_pad=0
            local _usagi_quote_padding=""
            (( _usagi_quote_pad > 0 )) && _usagi_quote_padding="${(l:_usagi_quote_pad:: :)}"
            print ""
            print "${_usagi_quote_padding}  ${_usagi_color_quote}${_usagi_quote_text}${_usagi_color_reset}"
        fi

        print ""
    }

    # Trap WINCH (window size change) to re-render, but do not clear the terminal
    TRAPWINCH() {
        usagi_render_banner
    }

    # Initial render
    usagi_render_banner
}
