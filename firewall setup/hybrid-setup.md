## Hybrid firewall setup



```
                                INTERNET
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │  ISP-1 DC1  │ │   GCP CLOUD │ │  ISP-2 DC2  │
            │   Router    │ │             │ │   Router    │
            └─────────────┘ │ Cloud NAT   │ └─────────────┘
                    │       │ Load Bal.   │       │
                    │       │ Firewall    │       │
                    │       │ Cloud Armor │       │
                    │       └─────────────┘       │
                    │              │              │
                    │         ┌────┴────┐         │
                    │         │ VPN Hub │         │
                    │         └────┬────┘         │
                    │              │              │
               ┌────┴────┐    ┌────┴────┐    ┌───┴─────┐
               │IPSec VPN│    │IPSec VPN│    │IPSec VPN│
               │Tunnel-1 │    │Tunnel-2 │    │Tunnel-3 │
               └────┬────┘    └────┬────┘    └───┬─────┘
                    │              │              │
              ┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐
              │    DC1    │  │    DR     │  │    DC2    │
              │ Primary   │  │  Site     │  │ Secondary │
              │Data Center│  │           │  │Data Center│
              └───────────┘  └───────────┘  └───────────┘
                    │              │              │
              ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
              │Employee   │  │Employee   │  │Employee   │
              │Workstation│  │Workstation│  │Workstation│
              └───────────┘  └───────────┘  └───────────┘
                    │              │              │
              ┌─────┴─────┐        │        ┌─────┴─────┐
              │  TRAFFIC  │        │        │  TRAFFIC  │
              │  ROUTING  │        │        │  ROUTING  │
              │           │        │        │           │
              │Business   │        │        │Business   │
              │Apps    ──────────────────────────────────────► GCP
              │CRM/ERP    │        │        │CRM/ERP    │
              │Database   │        │        │Database   │
              │           │        │        │           │
              │General    │        │        │General    │
              │Internet ─────► Local Router │Internet ─────► Local Router
              │YouTube    │        │        │YouTube    │
              │Updates    │        │        │Updates    │
              │Streaming  │        │        │Streaming  │
              └───────────┘        │        └───────────┘
```



REMOTE WORKERS:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Home-1    │    │   Home-2    │    │   Home-N    │
│  Employee   │    │  Employee   │    │  Employee   │
└─────┬───────┘    └─────┬───────┘    └─────┬───────┘
      │                  │                  │
      └──────────────────┼──────────────────┘
                         │
                  ┌──────▼──────┐
                  │  Cloud VPN  │
                  │   Gateway   │
                  └──────┬──────┘
                         │
                    ┌────▼────┐
                    │   GCP   │
                    │   Hub   │
                    └─────────┘
                         │
                    Routes to appropriate DC
```

TRAFFIC FLOW LEGEND:
═══════════════════════════════════════════════════════════

Business/Critical Traffic:
Employee → Local Network → VPN Tunnel → GCP → Cloud NAT → Internet

General Internet Traffic:  
Employee → Local Network → Local ISP Router → Direct Internet

Remote Worker Traffic:
Home → Cloud VPN → GCP Hub → Route to DC (if needed) or Internet

Health Check & Failover:
GCP Load Balancer monitors DC1/DC2 health and routes accordingly
