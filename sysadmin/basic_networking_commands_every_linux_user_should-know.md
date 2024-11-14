# Basic Networking Commands Every Linux User Should Know

## MTR

 You might be confused whether to use `ping` or `traceroute`. Why not use both? That's what `mtr`, or *My Traceroute*, does: you get the route your packets take while you can see statistics, since `mtr` runs continually.

What's fascinating is to watch the statistics continually update. You'll often see one or two hops that are slower than the others along the way. This means that there's a bottleneck holding up traffic along the way.

`mtr` can also illustrate how paths through the network between machines can change with each run.

## tcpdump

`tcpdump` is a packet sniffer (a counterpart to the popular *Wireshark* program). With `tcpdump`, you can see the packets that your machine is sending out. Because this shows all the traffic on an interface, you usually need to be root to run it.

This will show all packets being sent and received on the default network interface in real time. This is a useful diagnostic, but it can also be used to spy on internet traffic. Fortunately, it's more common for internet traffic these days to be encrypted, so if someone got a hold of your transmissions, it would be useless unless they found a way to decode it.

## whois

`whois` will return the official records of a domain name, which can be useful if you need to get in touch with an admin at a website to report a problem. It's also possible to abuse this, which is why it's possible to register a domain name anonymously.

You'll see a lot of the same information in `dig` or `host`, but you'll also see the contact information of whoever registered the domain name. If the site owner doesn't want their name and address accessible to anyone who knows how to run a whois query, the domain name will often be registered by a corporation that sells domain names. You'll also see when the domain name was registered and when it expires.