# Set basic helper for resetting color
local rc=$reset_color

# RPROMPT="%F{194}%K{005}[%D{%y/%m/%f}|%@]%{$rc%}"
# PROMPT="%F{240}%n%F{red}@%F{green}%m:%F{141}%d %{$rc%}%% "
# PS1='%(?.%F{green}.%F{green})%n@%m:%~%# %f'

# purple username
username() {
   echo "%{$FG[012]%}%n%{$reset_color%}"
}

# current directory, two levels deep
directory() {
   echo "%2~"
}

# current time with milliseconds
current_time() {
   echo "%*"
}

# returns 👾 if there are errors, nothing otherwise
return_status() {
   echo "%(?..👾)"
}

# putting it all together
export PROMPT="%B$(username) $(directory)%b "
export RPROMPT="$(current_time)$(return_status)"
