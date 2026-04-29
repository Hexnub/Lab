Default policy = drop (blocks everything incoming)
Only allows traffic from the specific IP + port combinations
Allows ICMP but limits rate to 5/second

```config
#!/usr/sbin/nft -f

flush ruleset
table inet firewall {
    set allowed_ips {
        type ipv4_addr . inet_service
        flags constant
        elements = {
            172.16.0.112 . 22,
            172.16.0.108 . 22,
            172.16.0.112 . 8080,
            172.16.0.108 . 8080
        }
    }

    chain ingress {
        type filter hook input priority filter; policy drop;
        iif "lo" accept
        ct state { established, related } accept
        ct state invalid drop
        ip saddr . tcp dport @allowed_ips accept
        ip protocol icmp icmp type echo-request limit rate over 5/second burst 10 packets drop
        ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded, parameter-problem } accept
    }
}
```