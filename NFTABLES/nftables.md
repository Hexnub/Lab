# NFTABLES

list current ruleset
```bash
nft list ruleset
```

remove all rullset leaving the system with no firewall
```bash
nft flush ruleset
```

To read input from a file use the -f/--file option:
```bash
nft --file filename
```
### basic sample config
config file: /etc/nftables.conf
```
#!/usr/bin/nft -f
# vim:set ts=2 sw=2 et:

# IPv4/IPv6 Simple & Safe firewall ruleset.
# More examples in /usr/share/nftables/ and /usr/share/doc/nftables/examples/.

destroy table inet filter
table inet filter {
  chain input {
    type filter hook input priority filter
    policy drop

    ct state invalid drop comment "early drop of invalid connections"
    ct state {established, related} accept comment "allow tracked connections"
    iif lo accept comment "allow from loopback"
    meta l4proto { icmp, icmpv6 } accept comment "allow icmp"
    tcp dport ssh accept comment "allow sshd"
    pkttype host limit rate 5/second counter reject with icmpx type admin-prohibited
    counter
  }
  chain forward {
    type filter hook forward priority filter
    policy drop
  }
}
```

### packet counters

 counters can be added to count accepted or dropped packets
```
counter accept 
counter drop
```

Example:
```
flush ruleset
table inet firewall {
    chain ingress {
        type filter hook input priority filter;
        policy accept
        ct state { established, related } counter accept
        iif lo counter accept
        tcp dport 22 counter accept
        counter drop
    }
}

```

counters can also be added as a regular chain and the name referenced in the base chain
```
# regular chain

counter cnt_example {
}

# base chain
# To add a base chain it is mandatory to specify type, hook and priority values

chain filter {
    type filter hook input priority 1
    policy drop
    ct state { established, related } counter name cnt_sample
    }
```

### Adding IP Set

IPs can be added directly to the base chain:
```
flush ruleset
table inet firewall {
    chain ingress {
        type filter hook input priority filter;
        policy accept
        ct state { established, related } counter accept
        iif lo counter accept
        ct state new ip saddr { 172.16.0.112, 172.16.0.108 } tcp dport { 22, 8080 }
        tcp dport 22 counter accept
        counter drop
    }
}
```

Organizational Ideas
IPs can be added to a named set regular chain and referenced in the base chain

You can include the destination port with a . separator in the IP element
ip saddr . tcp dport
```
flush ruleset
table inet firewall {
    set allowed_ips {
        typeof ip saddr . tcp dport
        elements = { 172.16.0.112 . 22, 
                     172.16.0.108 . 22,
                     172.16.0.112 . 8080, 
                     172.16.0.108 . 8080
                   }
    }
    chain ingress {
        type filter hook input priority filter;
        policy accept
        ct state { established, related } counter accept
        iif lo counter accept
        ct state new ip saddr . tcp dport  @allowed_ips
        tcp dport 22 counter accept
        counter drop
    }
}
```

interval flag is required for adding IP address ranges including ranges added via CIDR notation
```
flush ruleset
table inet firewall {
    set allowed_ips {
        typeof ip saddr
        flags interval
        elements = { 172.16.0.112, 172.16.0.108,
                     192.168.0.0/16,
                     172.16.80.0 - 172.16.80.123 }
    }
    chain ingress {
        type filter hook input priority filter;
        policy accept
        ct state { established, related } counter accept
        iif lo counter accept
        ct state new ip saddr @allowed_ips tcp dport { 22, 8080 }
        tcp dport 22 counter accept
        counter drop
    }
}
```

auto-merge keyword is a powerful tool that will allow merging of IP address ranges.
```
table ip name {
    set allowed_ips {
        typeof ip saddr
        flags interval
        auto-merge
        elements = { 172.16.0.112, 172.16.0.108,
                     192.168.0.0/16,
                     172.16.80.0 - 172.16.80.123 }
    }
}

```

Separate IPs and ports
```
flush ruleset
table inet firewall {
    set allowed_ips {
        typeof ip saddr
        elements = { 172.16.0.112, 172.16.0.108 }
    }
    set tcp_ports  {
        typeof tcp dport
        elements = { 22, 80 }
    }
    set udp_ports {
        typesof udp dport
        elements = {}
    }
    chain ingress {
        type filter hook input priority filter;
        policy accept
        ct state { established, related } counter accept
        iif lo counter accept
        ip saddr @allowed_ips ct state new accept
        # tcp dport @tcp_ports ct state new accept
        # tcp dport 22 counter accept
        counter drop
    }
}
```

### Use of type & typeof in sets 

| If you want to match | Use typeof          | Use type          |
|----------------------|---------------------|-------------------|
| 'Source/Dest'        | IP,typeof ip saddr  | type ipv4_addr    |
| 'Source/Dest IPv6'   | typeof ip6 saddr    | type ipv6_addr    |
| 'TCP/UDP Ports'      | typeof tcp dport    | type inet_service |
| 'MAC Addresses'      | typeof ether saddr  | type ether_addr   |
| 'Interface names'    | typeof iifname      | type ifname       |
| 'ICMP Types'         | typeof icmp type    | type icmp_type    |

### jump vs. goto
jump: When the sub-chain finishes, the packet comes back to the original chain to continue with the next rule.
goto: The packet moves to the new chain and never comes back to the original chain.

jump examples
```
table inet filter {
    # 1. Define the jump target chain (no hook)
    chain manage_icmp {
        # Rate limit pings to 5 per second
        icmp type echo-request limit rate 5/second accept
        
        # Accept essential ICMP types for Path MTU discovery
        icmp type { destination-unreachable, time-exceeded } accept
        
        # Drop everything else ICMP-related
        drop
    }

    chain input {
        type filter hook input priority filter; policy drop;

        # 2. Jump to the ICMP chain if the protocol matches
        meta l4proto { icmp, icmpv6 } jump manage_icmp

    }
}
```

```
table inet filter {
    # 1. Define a dedicated logging chain
    chain log_and_drop {
        # Log with a prefix and limit to avoid filling disk space
        limit rate 3/minute log prefix "FIREWALL_DROP: " 
        
        # Terminal action: the packet stops here
        drop
    }

    chain input {
        type filter hook input priority filter; policy accept;

        # Allow trusted traffic
        tcp dport { 80, 443 } accept

        # 2. Jump to logging for anything else instead of just dropping
        jump log_and_drop
    }
}
```
goto example
```
table inet filter {

    # ROOM A: The ICMP Specialist (A Jump Chain)
    # We "jump" here to check the packet, then we return to the hallway.
    chain check_icmp {
        icmp type echo-request limit rate 5/second accept
        icmp type { destination-unreachable, time-exceeded } accept
        # If it doesn't match above, it "returns" to the main chain
    }

    # ROOM B: The Exit (A Goto Chain)
    # Once a packet enters here, it is finished. No returning.
    chain log_and_drop {
        limit rate 3/minute log prefix "REJECTED: "
        drop
    }

    # THE MAIN HALLWAY (The Input Chain)
    chain input {
        type filter hook input priority filter; 
        policy accept; # The 'log_and_drop' chain will handle the final 'drop'

        # 1. Always allow established traffic first (Efficiency)
        ct state established, related accept

        # 2. Handle ICMP (The Jump)
        # The packet goes to 'check_icmp'. If it's a valid ping, it's accepted there.
        # If it's NOT a valid ping, it comes BACK here to keep moving down.
        meta l4proto icmp jump check_icmp

        # 3. Handle Web Traffic
        tcp dport { 80, 443 } accept

        # 4. Handle Everything Else (The Goto)
        # We are done with this packet. Send it to the exit.
        goto log_and_drop
        
        # --- NOTHING BELOW THIS LINE WILL EVER RUN ---
    }
}
```

Final Config with explaination
```
#!/usr/sbin/nft -f
# Recommended: save as /etc/nftables.conf or ~/firewall.nft
# Apply with: sudo nft -f /path/to/this/file

flush ruleset

table inet flexible-firewall {

    # ────────────────────────────────────────────────
    # Sets – these are dynamic collections you can modify on the fly
    # ────────────────────────────────────────────────

    # Trusted source IPs – add/remove individual IPs or CIDR ranges
    set allowed_ips_v4 {
        type ipv4_addr
        flags interval           # allows adding subnets like 192.168.10.0/24
        elements = { 192.168.10.0/24, 192.168.12.5 }
    }

    set allowed_ips_v6 {
        type ipv6_addr
        flags interval
        elements = { }
    }

    # Allowed TCP ports (new incoming connections)
    set allowed_tcp_ports {
        type inet_service
        elements = { 22, 80, 443 }     # SSH + HTTP + HTTPS – add more as needed
    }

    # Allowed UDP ports (new incoming connections)
    set allowed_udp_ports {
        type inet_service
        elements = { }                 # empty with space, as requested
    }


    # ────────────────────────────────────────────────
    # Main input chain – single entry point for incoming packets
    # ────────────────────────────────────────────────

    chain input {
        type filter hook input priority filter; policy drop;

        # Accept anything on loopback interface (very important)
        iifname "lo" accept comment "Loopback traffic"

        # Drop invalid / malformed packets early
        ct state invalid drop comment "Drop invalid connections"

        # Fast-path: accept already established and related connections
        ct state { established, related } accept comment "Established/related"

        # Allow new connections only from explicitly trusted IPs
        ip saddr @allowed_ips_v4  accept comment "Trusted IPv4 – any port"
        ip6 saddr @allowed_ips_v6 accept comment "Trusted IPv6 – any port"

        # For other sources → only allow specific ports via jump chains
        tcp dport @allowed_tcp_ports  jump chain_tcp_new
        udp dport @allowed_udp_ports  jump chain_udp_new

        # Handle ICMP / ICMPv6 separately
        jump chain_icmp

        # Everything else is dropped by policy
    }


    # ────────────────────────────────────────────────
    # Protocol-specific chains – easy to extend later
    # ────────────────────────────────────────────────

    chain chain_tcp_new {
        # You can add extra restrictions here later, e.g.:
        # tcp dport 22 ct state new limit rate 6/minute accept
        accept comment "Allowed new TCP connections to permitted ports"
    }

    chain chain_udp_new {
        accept comment "Allowed new UDP connections to permitted ports"
    }


    # ────────────────────────────────────────────────
    # ICMP control – pick the style you prefer (examples below)
    # ────────────────────────────────────────────────

    chain chain_icmp {
        # === Option A: Rate-limit incoming pings (recommended) ===
        icmp type echo-request limit rate over 5/second burst 8 packets drop comment "Prevent ping floods IPv4"
        icmp type echo-request accept

        icmpv6 type echo-request limit rate over 5/second burst 8 packets drop comment "Prevent ping floods IPv6"
        icmpv6 type echo-request accept

        # Always allow critical ICMPv6 types for IPv6 to work properly
        icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem,
                      nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert,
                      mld-listener-query, mld-listener-report, mld-listener-reduction } accept

        # === Option B: Completely block incoming pings ===
        # icmp type echo-request drop
        # icmpv6 type echo-request drop

        # === Option C: Allow unlimited pings ===
        # icmp type echo-request accept
        # icmpv6 type echo-request accept
    }
}
```
Template
Recommended: save as /etc/nftables.conf
```
#!/usr/sbin/nft -f

flush ruleset

table inet flexible-firewall {

    set allowed_ips_v4 {
        type ipv4_addr
        flags interval
        elements = { }
    }

    set allowed_ips_v6 {
        type ipv6_addr
        flags interval
        elements = { }
    }

    set allowed_tcp_ports {
        type inet_service
        elements = { }
    }

    set allowed_udp_ports {
        type inet_service
        elements = { }
    }

    chain input {
        type filter hook input priority filter; policy drop;

        iifname "lo" accept
        ct state invalid drop
        ct state { established, related } accept

        ip saddr @allowed_ips_v4  accept
        ip6 saddr @allowed_ips_v6 accept

        tcp dport @allowed_tcp_ports  jump chain_tcp_new
        udp dport @allowed_udp_ports  jump chain_udp_new

        jump chain_icmp
    }

    chain chain_tcp_new {
        accept
    }

    chain chain_udp_new {
        accept
    }

    chain chain_icmp {
        icmp type echo-request limit rate over 5/second burst 8 packets drop
        icmp type echo-request accept
        icmpv6 type echo-request limit rate over 5/second burst 8 packets drop
        icmpv6 type echo-request accept

        icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem,
                      nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert,
                      mld-listener-query, mld-listener-report, mld-listener-reduction } accept
    }
}
``` 