# Multi-ISP Configuration for AMD EPYC 7543 Firewall Setup

## **🎯 Multi-ISP Architecture Overview**

Your firewall needs to handle **multiple ISP connections** for redundancy, load balancing, and increased bandwidth. <cite index="165-1">pfSense software is capable of handling numerous WAN interfaces, with multiple deployments using over 10 WANs in production</cite>.

---

## **Port Requirements Analysis**

### **Minimum Port Requirements for Multi-ISP Setup**

```
┌─────────────────────────────────────────────────────────┐
│               PORT ALLOCATION TABLE                     │
├─────────────────────┬─────────────────┬─────────────────┤
│ Interface Type      │ Ports Required  │ Recommended     │
├─────────────────────┼─────────────────┼─────────────────┤
│ WAN Connections     │ 4-6 ports       │ 6 ports         │
│ ├── Primary ISP     │ 1 port          │ 2 ports (HA)    │
│ ├── Secondary ISP   │ 1 port          │ 2 ports (HA)    │
│ ├── Tertiary ISP    │ 1 port          │ 1 port          │
│ └── Backup 4G/5G    │ 1 port          │ 1 port          │
│                     │                 │                 │
│ LAN Segments        │ 4-8 ports       │ 8 ports         │
│ ├── Core LAN        │ 2 ports         │ 4 ports (LACP)  │
│ ├── DMZ Network     │ 1 port          │ 2 ports         │
│ ├── Management      │ 1 port          │ 1 port          │
│ └── Guest Network   │ 1 port          │ 1 port          │
│                     │                 │                 │
│ **TOTAL REQUIRED**  │ **8-14 ports**  │ **14-16 ports** │
└─────────────────────┴─────────────────┴─────────────────┘
```

### **🏆 Recommended Network Card Configuration**

#### **Primary NIC: Intel X710-DA4 (Quad-Port 10GbE SFP+)**
```
Ports: 4x 10GbE SFP+ 
Purpose: High-speed WAN connections
Connection: PCIe 3.0 x8
Price: ~₹1,50,000 INR
Use Case: Primary and Secondary ISP connections
```

#### **Secondary NIC: Intel I350-T4 (Quad-Port GbE)**
```
Ports: 4x 1GbE RJ45
Purpose: Additional ISPs and management
Connection: PCIe 2.1 x4
Price: ~₹25,000 INR
Use Case: Backup ISPs, management, monitoring
```

#### **Additional NIC: Intel X550-T2 (Dual-Port 10GbE)**
```
Ports: 2x 10GbE RJ45
Purpose: LAN connectivity
Connection: PCIe 3.0 x8
Price: ~₹45,000 INR
Use Case: Core LAN and DMZ connections
```

---

## **Complete Multi-ISP Network Architecture**

### **Physical Network Diagram**

```
                            INTERNET
                               │
        ┌──────────────────────┼──────────────────────┐
        │                     │                      │
   ┌────▼────┐           ┌────▼────┐            ┌────▼────┐
   │  ISP 1  │           │  ISP 2  │            │  ISP 3  │
   │ Fiber   │           │ Cable   │            │  5G     │
   │20Gbps   │           │10Gbps   │            │1Gbps    │
   └────┬────┘           └────┬────┘            └────┬────┘
        │                     │                      │
        │ 10GbE SFP+         │ 10GbE RJ45          │ 1GbE RJ45
        │                     │                      │
   ┌────▼─────────────────────▼──────────────────────▼────┐
   │              AMD EPYC 7543 FIREWALL                  │
   │  ┌─────────────────────────────────────────────────┐ │
   │  │           NETWORK INTERFACE CARDS               │ │
   │  │                                                 │ │
   │  │ Intel X710-DA4 (4x 10GbE SFP+)                │ │
   │  │ ├── Port 1: ISP 1 Primary (10GbE)             │ │
   │  │ ├── Port 2: ISP 1 Backup (10GbE)              │ │
   │  │ ├── Port 3: ISP 2 Primary (10GbE)             │ │
   │  │ └── Port 4: Core LAN Uplink (10GbE)           │ │
   │  │                                                 │ │
   │  │ Intel I350-T4 (4x 1GbE RJ45)                  │ │
   │  │ ├── Port 1: ISP 3 Backup (1GbE)               │ │
   │  │ ├── Port 2: Management Network (1GbE)          │ │
   │  │ ├── Port 3: Monitoring/SIEM (1GbE)            │ │
   │  │ └── Port 4: Out-of-Band Management (1GbE)      │ │
   │  │                                                 │ │
   │  │ Intel X550-T2 (2x 10GbE RJ45)                 │ │
   │  │ ├── Port 1: DMZ Network (10GbE)                │ │
   │  │ └── Port 2: Guest Network (10GbE)              │ │
   │  └─────────────────────────────────────────────────┘ │
   └──────────────────────┬──────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
   │ CORE    │      │  DMZ    │      │ GUEST   │
   │ SWITCH  │      │ SWITCH  │      │ SWITCH  │
   │ 48x10GbE│      │ 24x10GbE│      │ 24x1GbE │
   └─────────┘      └─────────┘      └─────────┘
```

### **Logical ISP Configuration**

#### **ISP Failover Hierarchy**
<cite index="160-1">The firewall prefers gateways on a lower number tier. If gateways on the lowest tier are down, it looks for gateways on a higher number tier</cite>

```
┌─────────────────────────────────────────────────────────┐
│                ISP PRIORITY TIERS                       │
├─────────────┬─────────────┬─────────────┬──────────────┤
│ Tier 1      │ Tier 2      │ Tier 3      │ Tier 4       │
│ (Primary)   │ (Secondary) │ (Tertiary)  │ (Emergency)  │
├─────────────┼─────────────┼─────────────┼──────────────┤
│ ISP 1       │ ISP 2       │ ISP 3       │ 5G Backup   │
│ Fiber 20G   │ Cable 10G   │ DSL 1G      │ Cellular 1G  │
│ Weight: 3   │ Weight: 2   │ Weight: 1   │ Weight: 1    │
│ 99.9% SLA   │ 99.5% SLA   │ 99% SLA     │ Best Effort  │
└─────────────┴─────────────┴─────────────┴──────────────┘
```

---

## **Detailed Hardware Configuration**

### **🏆 Complete AMD EPYC 7543 Multi-ISP Server Build**

#### **Server Specifications**
```
CHASSIS: Dell PowerEdge R7515 (2U Rackmount)
├── CPU: AMD EPYC 7543 (32C/64T, 2.8GHz base, 3.7GHz boost)
├── RAM: 128GB DDR4-3200 ECC (8x 16GB modules)
├── Storage: 2x 960GB NVMe SSD (RAID 1) + 4x 4TB SATA (RAID 5)
├── PSU: Dual 750W 80+ Platinum (redundant)
├── Management: iDRAC9 Enterprise
└── Form Factor: 2U, 19" rack mountable
```

#### **Network Interface Cards (Total Cost: ~₹2,20,000)**
| NIC Model | Ports | Speed | Purpose | Price (INR) |
|-----------|-------|--------|---------|-------------|
| **Intel X710-DA4** | 4x SFP+ | 10GbE | Primary WAN | ₹1,50,000 |
| **Intel I350-T4** | 4x RJ45 | 1GbE | Secondary WAN/Mgmt | ₹25,000 |
| **Intel X550-T2** | 2x RJ45 | 10GbE | LAN Segments | ₹45,000 |
| **TOTAL** | **10 Ports** | **Mixed** | **Complete Setup** | **₹2,20,000** |

#### **SFP+ Modules & Cables**
```
SFP+ MODULES (for fiber connections):
├── 4x 10GBASE-SR SFP+ (850nm, up to 300m): ₹8,000 each
├── 2x 10GBASE-LR SFP+ (1310nm, up to 10km): ₹15,000 each
├── 4x 10GBASE-T SFP+ (RJ45 copper): ₹5,000 each
└── Total SFP+ cost: ₹62,000

CABLES:
├── 4x 10G SFP+ DAC Cables (1-3m): ₹3,000 each
├── 6x Cat6A Cables (various lengths): ₹500 each
├── 2x Fiber Optic Cables (single/multi-mode): ₹2,000 each
└── Total cable cost: ₹19,000
```

---

## **Software Configuration Guide**

### **OPNsense Multi-WAN Configuration**

#### **Step 1: Gateway Configuration**
<cite index="161-1">OPNsense offers 5 tiers (Failover groups) each tier can hold multiple ISPs/WAN gateways</cite>

```bash
# Navigate to System → Gateways → Single

Gateway Name: ISP1_PRIMARY
Interface: WAN1 (ix0)
Address Family: IPv4
IP Address: 203.0.113.1
Upstream Gateway: Auto
Monitor IP: 8.8.8.8
Weight: 3
Priority: 1

Gateway Name: ISP2_SECONDARY  
Interface: WAN2 (ix1)
Address Family: IPv4
IP Address: 198.51.100.1
Upstream Gateway: Auto
Monitor IP: 8.8.4.4
Weight: 2
Priority: 2

Gateway Name: ISP3_BACKUP
Interface: WAN3 (ix2)
Address Family: IPv4
IP Address: 192.0.2.1
Upstream Gateway: Auto
Monitor IP: 1.1.1.1
Weight: 1
Priority: 3
```

#### **Step 2: Gateway Groups Configuration**
<cite index="160-1">Gateway Groups are necessary components of a Load Balancing or Failover configuration</cite>

```yaml
# Load Balancer Group
Group Name: MultiWAN_LoadBalance
Gateways:
  - ISP1_PRIMARY (Tier 1, Weight 3)
  - ISP2_SECONDARY (Tier 1, Weight 2)
  - ISP3_BACKUP (Tier 2, Weight 1)
Trigger Level: Member Down

# Failover Group  
Group Name: MultiWAN_Failover
Gateways:
  - ISP1_PRIMARY (Tier 1)
  - ISP2_SECONDARY (Tier 2) 
  - ISP3_BACKUP (Tier 3)
Trigger Level: Member Down

# Critical Services Group (Banking, VoIP)
Group Name: Critical_Failover
Gateways:
  - ISP1_PRIMARY (Tier 1)
  - ISP2_SECONDARY (Tier 2)
Trigger Level: Packet Loss
```

#### **Step 3: Firewall Rules Configuration**

```yaml
# Default Load Balancing Rule
Interface: LAN
Protocol: any
Source: LAN net
Destination: any
Gateway: MultiWAN_LoadBalance
Description: "Default load balanced internet access"

# Critical Services Failover
Interface: LAN  
Protocol: TCP/UDP
Source: LAN net
Destination: Banking_Servers (alias)
Ports: 443, 80
Gateway: Critical_Failover
Description: "Banking/Financial services failover only"

# VoIP Traffic Sticky Connections
Interface: LAN
Protocol: UDP
Source: LAN net  
Destination: any
Ports: 5060, 10000-20000
Gateway: ISP1_PRIMARY
Advanced: Sticky connections enabled
Description: "VoIP traffic on primary ISP only"
```

### **Advanced Multi-WAN Features**

#### **Health Monitoring Configuration**
<cite index="162-1">For WAN or ISP-based gateways, you must enter a well-known public IP address to ensure that failover works properly, such as 8.8.8.8 or 8.8.4.4</cite>

```yaml
# ISP Health Check Settings
Monitor Settings:
  Probe Interval: 1 second
  Loss Threshold: 10%
  High Latency: 500ms
  High Packet Loss: 20%
  Down Threshold: 5 consecutive failures

# Probe Targets per ISP:
ISP1_Targets:
  - 8.8.8.8 (Google DNS)
  - 1.1.1.1 (Cloudflare DNS)
  - ISP_Gateway_IP

ISP2_Targets:  
  - 8.8.4.4 (Google DNS)
  - 9.9.9.9 (Quad9 DNS)
  - ISP_Gateway_IP

ISP3_Targets:
  - 208.67.222.222 (OpenDNS)
  - ISP_Gateway_IP
```

#### **Policy-Based Routing**
<cite index="159-1">Use Policy-Based Routing to create a rule that assigns the desired device(s) or VLAN as the Source and the dedicated WAN as the Interface</cite>

```yaml
# Department-specific routing
Sales_Department:
  Source: 10.10.10.0/24
  Gateway: ISP1_PRIMARY
  Failover: ISP2_SECONDARY

Development_Team:
  Source: 10.10.20.0/24  
  Gateway: ISP2_SECONDARY
  Failover: ISP3_BACKUP

Guest_Network:
  Source: 10.10.99.0/24
  Gateway: ISP3_BACKUP
  No_Failover: true (isolated)
```

---

## **ISP Connection Types & Requirements**

### **Recommended ISP Mix for Redundancy**

#### **Primary ISP: Dedicated Fiber (Tier 1)**
```
Technology: FTTH/Dedicated Fiber
Bandwidth: 20 Gbps symmetrical
SLA: 99.9% uptime
Latency: <5ms
Connection: 10GbE SFP+ (redundant)
Monthly Cost: ₹50,000-80,000
Providers: Jio, Airtel, BSNL Enterprise
```

#### **Secondary ISP: Cable/Broadband (Tier 2)**
```
Technology: Cable/Hybrid Fiber
Bandwidth: 10 Gbps down / 1 Gbps up
SLA: 99.5% uptime
Latency: <15ms
Connection: 10GbE RJ45
Monthly Cost: ₹15,000-25,000
Providers: ACT, Hathway, Local Cable
```

#### **Tertiary ISP: DSL/Wireless (Tier 3)**
```
Technology: DSL/Fixed Wireless
Bandwidth: 1 Gbps symmetrical
SLA: 99% uptime
Latency: <25ms
Connection: 1GbE RJ45
Monthly Cost: ₹5,000-10,000
Providers: MTNL, Local ISPs
```

#### **Emergency Backup: 5G/4G (Tier 4)**
```
Technology: Cellular (5G/4G)
Bandwidth: 1 Gbps down / 100 Mbps up
SLA: Best effort
Latency: 20-50ms
Connection: USB/Ethernet modem
Monthly Cost: ₹2,000-5,000
Providers: Jio, Airtel, Vi
```

---

## **Network Performance Optimization**

### **Load Balancing Algorithms**
<cite index="162-1">Sophos Firewall uses a weighted round-robin algorithm for load balancing, distributing traffic among the links based on the weight specified for the links</cite>

#### **Traffic Distribution Strategy**
```
┌─────────────────────────────────────────────────────────┐
│            TRAFFIC ALLOCATION BY TYPE                   │
├───────────────────┬─────────────┬───────────────────────┤
│ Traffic Type      │ ISP Choice  │ Reasoning             │
├───────────────────┼─────────────┼───────────────────────┤
│ Web Browsing      │ Load Bal.   │ Maximize bandwidth    │
│ File Downloads    │ ISP1 (60%)  │ Highest speed         │
│ Video Streaming   │ ISP1/ISP2   │ Consistent bandwidth  │
│ VoIP/SIP         │ ISP1 only   │ Sticky connections    │
│ Banking/Finance   │ Failover    │ Stability priority    │
│ Backup/Sync      │ ISP3        │ Non-critical traffic  │
│ Guest Internet   │ ISP3        │ Isolated/limited      │
│ Management       │ ISP2        │ Dedicated path        │
└───────────────────┴─────────────┴───────────────────────┘
```

### **Bandwidth Aggregation**
```
Total Available Bandwidth:
├── ISP1: 20 Gbps (Primary fiber)
├── ISP2: 10 Gbps (Cable backup)  
├── ISP3: 1 Gbps (DSL backup)
└── Total: 31 Gbps aggregate

Effective Load Balanced Bandwidth:
├── HTTP/HTTPS: ~25-28 Gbps
├── File Transfer: ~20-22 Gbps
├── Streaming: ~18-20 Gbps
└── Mixed Traffic: ~22-25 Gbps
```

---

## **Hardware Costs & Indian Pricing**

### **Complete Multi-ISP Setup Cost (INR)**

| Component | Specification | New Price | Refurbished Price | Recommended |
|-----------|---------------|-----------|-------------------|-------------|
| **Server** | Dell R7515 + EPYC 7543 + 128GB | ₹15,75,000 | **₹5,25,000** | **Refurbished** |
| **Primary NIC** | Intel X710-DA4 (4x10GbE) | ₹1,50,000 | ₹85,000 | New |
| **Secondary NIC** | Intel I350-T4 (4x1GbE) | ₹25,000 | ₹15,000 | Either |
| **LAN NIC** | Intel X550-T2 (2x10GbE) | ₹45,000 | ₹25,000 | Either |
| **SFP+ Modules** | 10x Mixed SFP+ transceivers | ₹62,000 | ₹35,000 | New |
| **Cables** | Various network cables | ₹19,000 | ₹10,000 | New |
| **Switch (Core)** | 48-port 10GbE switch | ₹3,50,000 | ₹1,50,000 | Refurbished |
| **UPS** | 10kVA Online UPS | ₹2,00,000 | ₹1,00,000 | Either |
| | | | | |
| **TOTAL** | **Complete Setup** | **₹23,26,000** | **₹10,45,000** | **₹10,45,000** |
| **Monthly ISP** | All 4 ISP connections | | **₹72,000/month** | |

### **🏆 Recommended Cost-Optimized Build**
```
Total Hardware Cost: ₹10,45,000 (55% savings with refurbished)
Monthly Operating Cost: ₹72,000 (all ISP connections)
Annual Total Cost: ₹19,09,000 (hardware + ISP costs)

ROI: Complete redundancy and 31 Gbps bandwidth capacity
Payback: 18-24 months vs commercial solutions
```

---

## **ISP Contract & SLA Considerations**

### **Contract Negotiation Points**

#### **Technical Requirements**
```
SLA Guarantees:
├── Uptime: 99.9% minimum (8.76 hours downtime/year)
├── Latency: <10ms for tier-1, <20ms for tier-2
├── Packet Loss: <0.1% during peak hours
├── Bandwidth: 95th percentile billing
└── MTTR: <4 hours for critical issues

Redundancy:
├── Diverse fiber paths (different routes)
├── Separate POPs (Points of Presence)  
├── Different backbone providers
├── Independent power/cooling systems
└── 24/7 NOC monitoring
```

#### **Commercial Terms**
```
Pricing Structure:
├── Volume discounts for multiple connections
├── Committed usage discounts (CUD)
├── Early termination clauses
├── Bandwidth burstability options
└── Professional installation included

Support Levels:
├── 24/7 NOC access with direct phone numbers
├── Escalation procedures and contacts
├── On-site technician response times
├── Remote monitoring and proactive alerts
└── Regular performance reports
```

---

## **Implementation Timeline & Steps**

### **Phase 1: Hardware Setup (Weeks 1-2)**
```
Week 1: Hardware Procurement
├── Order refurbished server from ServerBasket
├── Purchase network cards (new for reliability)
├── Order SFP+ modules and cables
└── Arrange rack space and power

Week 2: Physical Installation  
├── Rack and cable server
├── Install network interface cards
├── Initial OS installation (OPNsense)
└── Basic network connectivity testing
```

### **Phase 2: ISP Connections (Weeks 2-4)**
```
Week 2-3: ISP Orders & Provisioning
├── Sign contracts with 3-4 different ISPs
├── Schedule installation appointments
├── Coordinate fiber/cable routing
└── Arrange diverse entry points

Week 4: ISP Testing & Integration
├── Test each ISP connection individually  
├── Verify SLA compliance (bandwidth, latency)
├── Document IP addresses and routing
└── Implement basic failover
```

### **Phase 3: Software Configuration (Weeks 4-6)**  
```
Week 4-5: Multi-WAN Configuration
├── Configure gateway groups and policies
├── Implement load balancing rules
├── Set up health monitoring
└── Create policy-based routing rules

Week 5-6: Testing & Optimization
├── Perform failover testing
├── Load testing across all ISPs
├── Fine-tune traffic policies  
├── Document configuration
└── Train operations team
```

### **Phase 4: Production Cutover (Week 6)**
```
Production Migration:
├── Schedule maintenance window
├── Migrate services gradually
├── Monitor performance closely
├── Adjust policies based on real traffic
└── Document lessons learned
```

---

## **Monitoring & Management**

### **Key Metrics to Monitor**
```yaml
Per-ISP Metrics:
  - Bandwidth utilization (95th percentile)
  - Latency (average, max, jitter)
  - Packet loss percentage
  - Uptime/availability
  - Error rates

Overall Performance:
  - Total throughput
  - Connection distribution
  - Failover frequency
  - Recovery times
  - Cost per GB transferred

Business Impact:
  - User experience metrics
  - Application response times  
  - Revenue impact of outages
  - SLA compliance rates
```

### **Alerting Configuration**
```yaml
Critical Alerts (Immediate):
  - ISP completely down (>99% packet loss)
  - All ISPs degraded simultaneously
  - Firewall hardware failure
  - Security breach detected

Warning Alerts (15 minutes):  
  - ISP degraded performance (>5% packet loss)
  - Bandwidth utilization >90% 
  - Latency >2x normal
  - Gateway health check failures

Info Alerts (Daily):
  - Bandwidth usage reports
  - Cost utilization tracking
  - Performance trend analysis
  - Capacity planning updates
```

---

## **Final Recommendations**

### **🏆 Optimal Multi-ISP Configuration for Your Firewall**

```
RECOMMENDED SETUP:
├── Server: Dell R7515 (Refurbished) with EPYC 7543
├── Primary ISP: 20 Gbps Fiber (₹60,000/month)
├── Secondary ISP: 10 Gbps Cable (₹20,000/month) 
├── Backup ISP: 1 Gbps DSL (₹8,000/month)
├── Emergency: 5G Cellular (₹4,000/month)
├── Network Cards: 10 total ports (mixed 10GbE/1GbE)
├── Total Cost: ₹10,45,000 hardware + ₹92,000/month ISP
└── Result: 31 Gbps aggregate bandwidth with full redundancy
```

### **Key Success Factors**
1. **Diverse ISP Technologies**: Mix fiber, cable, DSL, cellular
2. **Separate Physical Paths**: Different cable routes and POPs  
3. **Proper Health Monitoring**: <cite index="162-1">Well-known public IP addresses for monitoring like 8.8.8.8</cite>
4. **Weighted Load Balancing**: <cite index="160-1">Different weights based on bandwidth capacity</cite>
5. **Policy-Based Routing**: Critical services on dedicated paths

This configuration ensures your 19.1 Gbps firewall requirements are met with significant overhead and complete redundancy across multiple ISP connections.
