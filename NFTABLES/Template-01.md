# Template 01
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
## Clean Template
### Recommended: save as /etc/nftables.conf
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