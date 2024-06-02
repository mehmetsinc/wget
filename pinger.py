import subprocess
import ipaddress

def ping_ip(ip):
    try:
        output = subprocess.check_output(["ping", "-c", "1", str(ip)], stderr=subprocess.STDOUT, universal_newlines=True)
        if "1 packets transmitted, 1 received" in output:
            return True
    except subprocess.CalledProcessError:
        return False

def get_live_ips(network, output_file):
    net = ipaddress.ip_network(network)
    live_ips = []
    with open(output_file, 'w') as f:
        for ip in net.hosts():
            print(f"Pinging {ip}...", end='', flush=True)
            f.write(f"Pinging {ip}...")
            if ping_ip(ip):
                print(" Alive")
                f.write(" Alive\n")
                live_ips.append(str(ip))
            else:
                print(" No response")
                f.write(" No response\n")
    return live_ips

if __name__ == "__main__":
    network = "10.10.12.0/24"
    output_file = "results.txt"
    live_ips = get_live_ips(network, output_file)
    with open(output_file, 'a') as f:
        f.write("\nLive IPs in the network:\n")
        for ip in live_ips:
            f.write(ip + "\n")
    print("\nLive IPs in the network:")
    for ip in live_ips:
        print(ip)
