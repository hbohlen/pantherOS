# Fish completions for network management
# Completions for common network tools and commands

# ip command completions
complete -c ip -n '__fish_use_subcommand' -a 'addr' -d 'Address management'
complete -c ip -n '__fish_use_subcommand' -a 'link' -d 'Network device management'
complete -c ip -n '__fish_use_subcommand' -a 'route' -d 'Routing table management'
complete -c ip -n '__fish_use_subcommand' -a 'neigh' -d 'Neighbor/ARP table management'
complete -c ip -n '__fish_use_subcommand' -a 'tunnel' -d 'Tunnel management'

# nmcli (NetworkManager) completions
complete -c nmcli -n '__fish_use_subcommand' -a 'connection' -d 'Connection management'
complete -c nmcli -n '__fish_use_subcommand' -a 'device' -d 'Device management'
complete -c nmcli -n '__fish_use_subcommand' -a 'general' -d 'General NetworkManager info'
complete -c nmcli -n '__fish_use_subcommand' -a 'networking' -d 'Network control'
complete -c nmcli -n '__fish_use_subcommand' -a 'radio' -d 'Radio control'

complete -c nmcli -n '__fish_seen_subcommand_from connection' -a 'show' -d 'Show connections'
complete -c nmcli -n '__fish_seen_subcommand_from connection' -a 'up' -d 'Activate connection'
complete -c nmcli -n '__fish_seen_subcommand_from connection' -a 'down' -d 'Deactivate connection'
complete -c nmcli -n '__fish_seen_subcommand_from connection' -a 'add' -d 'Add connection'
complete -c nmcli -n '__fish_seen_subcommand_from connection' -a 'delete' -d 'Delete connection'

# iwd (iNet wireless daemon) completions
complete -c iwctl -n '__fish_use_subcommand' -a 'station' -d 'Station management'
complete -c iwctl -n '__fish_use_subcommand' -a 'device' -d 'Device management'
complete -c iwctl -n '__fish_use_subcommand' -a 'adapter' -d 'Adapter management'
complete -c iwctl -n '__fish_use_subcommand' -a 'known-networks' -d 'Known networks'

# ss (socket statistics) completions
complete -c ss -s t -l tcp -d 'Show TCP sockets'
complete -c ss -s u -l udp -d 'Show UDP sockets'
complete -c ss -s l -l listening -d 'Show listening sockets'
complete -c ss -s n -l numeric -d 'Don\'t resolve service names'
complete -c ss -s p -l processes -d 'Show process using socket'

# ping completions
complete -c ping -s c -d 'Stop after N packets' -r
complete -c ping -s i -d 'Wait N seconds between packets' -r
complete -c ping -s W -d 'Timeout in seconds' -r
complete -c ping -s s -d 'Packet size' -r
