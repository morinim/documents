# Basic Networking Commands Every Linux User Should Know

## MTR

 You might be confused about whether to use `ping` or `traceroute`. Why not use both? That is what `mtr`, or _My Traceroute_, does: you get the route your packets take while you can see statistics, as `mtr` runs continually.

What is fascinating is watching the statistics update in real time. You will often see one or two hops that are slower than the others along the way. This usually indicates a **bottleneck** holding up traffic.

`mtr` can also illustrate how network paths between machines can change with each run.

## tcpdump

`tcpdump` is a packet sniffer (a command-line counterpart to the popular *Wireshark* program). With `tcpdump`, you can see the packets your machine is sending and receiving. Because it monitors all the traffic on an interface, you usually need **root privileges** to run it.

This tool shows all packets on the default network interface. While it is a vital diagnostic tool, it could potentially be used to monitor unencrypted traffic. Fortunately, most modern internet traffic is **encrypted**, meaning intercepted transmissions are effectively useless without the proper decryption keys.

## whois

`whois` returns the official records of a domain name, which is useful if you need to contact a website administrator to report a technical issue. Because this information can be misused, many owners choose to register their domains anonymously.

You'll see a lot of the same information in `dig` or `host`, but `whois` specifically highlights the contact details of the registrant. If the owner wishes to keep their name and address private, the domain will often be registered via a proxy corporation. You can also use this to check when a domain was first registered and when it is due to expire.

## nmcli

If you are using a modern distribution, `nmcli` (Network Manager Command Line Interface) is the standard tool for managing your connections. While older tools focused on viewing the state of the hardware, `nmcli` allows you to actively control it.

With `nmcli`, you can quickly see which network interfaces are active, connect to a new Wi-Fi access point, or toggle a VPN on and off without ever leaving the terminal. It is an essential tool for system administrators who need to configure network profiles on the fly or on headless servers where a graphical interface isn't available.

## iftop

Ever wondered why your internet connection feels sluggish? `iftop` is the network equivalent of the `top` command. It provides a real-time, visual representation of which external hosts are consuming your bandwidth.

Because `iftop` listens to all traffic on a named interface, you will typically need to run it with **sudo** privileges. It displays a list of connections and sorts them by how much data they are currently moving. This is incredibly useful for identifying "bandwidth hogs": whether that's a background system update or a rogue browser tab synchronising a large file.

## Deprecated command you should forget

The `net-tools` package has been deprecated, meaning man commands that were once staples of the Linux experience have been phased out.

- `ifconfig` → `ip`;
- `iwconfig` → `iw`;
- `ifup` / `ifdown` → `nmcli con up / down`
- `iwlist` (scanning for Wi-Fi) → `nmcli dev wifi list`
- `netstat` → `ss`;
- `route` → `ip route`;
- `arp` → `ip neighbour`;

Other commands you should consider replacing include:

- `scp` → `rsync`. The `scp` command was traditionally used to securely copy files via the SSH protocol. However, it is now considered legacy due to specific security vulnerabilities and has largely been superseded by `rsync`.
