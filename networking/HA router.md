<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# I am trying to create a Active active network path from one dc dr to my dc dr so there are total 2 mpls connection one mpls is equinix which is kind of a partner interconnect in GCP and another is from Tata which is a ip sec. And both are redundant . Now I want to achieve a active active resilience network connectivity like if equinix goes down all the trafic should use the Tata network if Tata goes down all the trafic goes through equinix and Tata are redundant in their respective way but I have to make multi region active active scnario. Please give me the architecture and the various way to do it

To achieve an active-active, resilient multi-region network connectivity between your on-premises data centers and Google Cloud Platform (GCP), using redundant circuits (one Equinix Partner Interconnect and one Tata IPsec), you should architect the connection with fast failover and load distribution. The goal is for traffic to automatically use one link if the other fails, and to allow traffic to use both links actively for better utilization and rapid disaster recovery.

### Key Architectural Principles

- Deploy active-active application stacks in both your data centers, with real-time or near-real-time data replication across sites, ensuring both can serve requests concurrently if needed.[^1_3][^1_5][^1_9]
- Use stateless architectures, or synchronize stateful resources efficiently, so that failover does not disrupt user experience.[^1_1][^1_7][^1_9]
- Both redundant connections (Equinix and Tata) must be provisioned with enough capacity to handle the full workload if one link goes down.[^1_6][^1_8]
- Routing policies should detect link failure and automatically reroute traffic, ideally with minimal disruption and zero recovery time (RTO=0).[^1_5][^1_3]


### Connectivity Strategies

#### 1. Equal-cost Multi-path (ECMP) Routing

- Configure your Cloud Routers and data center routers to announce the same routes over both connections with equal metrics (same CIDR, same MED values).
- GCP supports ECMP natively, balancing outbound traffic across the active links. If one link is lost, traffic shifts to the remaining path automatically.[^1_6]


#### 2. Dynamic Routing Protocols (BGP)

- Use BGP between your data center and GCP through both Partner Interconnect and IPsec/VPN.
- Ensure BGP route advertisements from both links are equally preferred, allowing outgoing and incoming traffic to use both paths.
- If a link fails, BGP withdraws that route, so all traffic uses the surviving path seamlessly.[^1_8][^1_6]


#### 3. Health Monitoring and Fast Failover

- Implement robust health checks (GCP supports these for Partner Interconnect and VPN).
- If a path fails, dynamic routing updates will occur, and traffic will redirect with minimal downtime.[^1_10][^1_8][^1_6]


#### 4. DNS-based Failover for Applications

- For applications at the global scale, consider using DNS (e.g., GCP Cloud DNS or external solutions) to direct users to the healthiest region or path, particularly for web-facing services.[^1_9][^1_1][^1_3]


#### 5. Multi-region Application Deployment

- Deploy application services in both regions (or DCs), ensuring both are equally capable of handling production traffic at any time.
- Synchronize databases and other stateful services via efficient replication (GCP has managed services for this).[^1_1][^1_5][^1_9]


### Example Architecture Diagram

- DC1 (on-premises) — Equinix Partner Interconnect → GCP
- DC1 (on-premises) — Tata IPsec VPN → GCP
- DC2 (GCP region or another DC) — Redundant connectivity as above
- Both Equinix and Tata connections terminate at a cloud route reflector (Cloud Router)
- BGP peering and ECMP enable active-active traffic flow
- Endpoints (servers/services) deployed in both locations
- DNS or global load balancer distributes traffic across DCs/regions


### Best Practices

- Always provision redundant connections in separate physical domains for true resilience.[^1_8][^1_6]
- Test failover scenarios regularly to ensure automatic recovery works as planned.[^1_7][^1_5]
- Monitor bandwidth, latency, and health for both paths to avoid silent failures or routing blackholes.[^1_10][^1_6]


### Ways to Achieve Multi-region Active-Active

- Use ECMP and BGP for dynamic, resilient path selection across redundant physical circuits.
- Implement DNS or load balancer–based routing at the application level for global resilience.
- Ensure both regions/applications are truly "active," not passive standbys.
- Deploy regular backup and replication strategies to keep data stores in sync.

This approach will provide resilience and redundancy so that traffic will always flow through at least one available path and you can serve users globally with minimal disruption.[^1_5][^1_9][^1_6]
<span style="display:none">[^1_2][^1_4]</span>

<div align="center">⁂</div>

[^1_1]: https://www.pluralsight.com/resources/blog/cloud/why-and-how-do-we-build-a-multi-region-active-active-architecture

[^1_2]: https://www.reddit.com/r/networking/comments/k1fcyx/activeactive_datacenters/

[^1_3]: https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-iv-multi-site-active-active/

[^1_4]: https://www.reddit.com/r/networking/comments/86hcb5/how_do_you_guys_handle_activeactive_internet/

[^1_5]: https://docs.confluent.io/platform/6.2/multi-dc-deployments/multi-region-architectures.html

[^1_6]: https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-overview

[^1_7]: https://awsforengineers.com/blog/multi-region-active-active-architecture-on-aws-guide/

[^1_8]: https://cloud.google.com/network-connectivity/docs/interconnect/how-to/dedicated/creating-redundant-interconnect

[^1_9]: https://dev.to/virajlakshitha/going-global-building-highly-resilient-systems-with-multi-region-active-active-architectures-3bk8

[^1_10]: https://cloud.google.com/network-connectivity/docs/interconnect/support/faq


---

# Out of below gcp interconnect vendor can you list or rank them according to their reliability and cost and give me a recommendation that will be better than quinix and there will be win win situations between cost and regilience

Based on the latest information for 2025, here’s an assessment and recommendation for GCP Interconnect vendors, focused on reliability and cost, and a suggestion for an option that could be better than Equinix (referred to here as "Quinix").

### GCP Interconnect Vendor Ranking (Reliability \& Cost)

| Vendor | Reliability | Cost | Key Notes |
| :-- | :-- | :-- | :-- |
| Google Dedicated Interconnect | Extremely High | Moderate-High | Direct physical link; backed by full Google SLA |
| Google Cross-Site Interconnect | Very High | Flexible (cloud consumption) | Newest; Layer 2, high uptime, pay-as-you-go[^2_3] |
| CoreSite (Partner) | High | Moderate | Strong uptime, on-demand options; scales to 100Gbps[^2_1] |
| Megaport (Partner) | High | Moderate | On-demand, flexible, commonly used for multi-cloud[^2_4] |
| Equinix (Partner) | Good-High | Moderate-High | Market leader, but often premium priced, strong support |
| Tata (IPSec/VPN) | Variable | Low-Moderate | VPN, not direct; may see higher latency or variability |

### Best-Balanced Recommendation

**Google Cross-Site Interconnect** is recommended over Equinix for environments where flexibility, cost savings, and resilience are priorities:

- It’s designed for high reliability, provides transparent, on-demand Layer 2 connectivity, and offers abstracted redundancy managed by Google itself—simplifying your operations and reducing your risk of single points of failure.[^2_3]
- Pricing is cloud consumption-based, so you avoid large upfront costs, non-recurring fees, and only pay for what you actually use, making it often more cost-effective than Dedicated or many Partner Interconnects.[^2_3]
- It’s inherently flexible, can sit alongside other connections, or completely replace existing Partner Interconnects for dual-path (active-active) and multi-region scenarios.


### Why Cross-Site Interconnect is Preferable

- Strong end-to-end availability SLA, maintained by Google, with built-in redundancy.
- Consumption-based billing, maximizing your cost efficiencies, especially at scale or under dynamic workloads.[^2_3]
- Simplifies WAN operations and risk mapping—Google abstracts most operational complexity and ensures your resilience requirements are met.[^2_3]
- Supports both active-active and active-passive network patterns with easy integration into existing VPC infrastructure.

This positions Cross-Site Interconnect as more cost-efficient and operationally resilient compared to Equinix for modern cloud networking needs in 2025.[^2_3]
<span style="display:none">[^2_10][^2_2][^2_5][^2_6][^2_7][^2_8][^2_9]</span>

<div align="center">⁂</div>

[^2_1]: https://www.coresite.com/cloud-networking/google-cloud-interconnect

[^2_2]: https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/overview

[^2_3]: https://cloud.google.com/blog/products/networking/cross-site-interconnect-now-ga-simplifies-l2-connectivity

[^2_4]: https://www.megaport.com/blog/six-key-differences-between-major-cloud-providers/

[^2_5]: https://thecodev.co.uk/cloud-providers-comparison-2025/

[^2_6]: https://cloud.google.com/blog/products/compute/google-is-a-leader-in-gartner-magic-quadrant-for-scps

[^2_7]: https://docs.cloud.google.com/docs/get-started/aws-azure-gcp-service-comparison

[^2_8]: https://blog.consoleconnect.com/whats-new-with-google-cloud-for-2025

[^2_9]: https://dev.to/davinceleecode/top-cloud-platform-providers-2025-le1

[^2_10]: https://cloud.google.com


---

# Yes actually I have a cloud router in google and I have a Tata router so can I use a middle router or switch and connect both the router there ?

Yes, you can use a middle router or a Layer 2 switch to connect both your Google Cloud Router and your Tata router as part of your network architecture. This setup is common in hybrid cloud and on-premises integrations where multiple paths and devices require interconnectivity and redundancy.[^3_4][^3_6][^3_9]

### How It Works

- Place a Layer 2 switch or an intermediate router between the Google Cloud Router (which handles BGP for GCP connections) and your Tata router (which manages your Tata IPsec/MPLS connection).
- This middle device acts as a bridge or traffic distribution point, allowing both routers to establish independent links and dynamic routing (using BGP).
- You can configure BGP sessions from both the Cloud Router and your Tata router via VLANs or interfaces on this middle device, ensuring that each path is advertised and monitored separately.[^3_6][^3_4]
- This setup lets you aggregate, load-balance, and quickly failover between Equinix and Tata circuits, while making management and monitoring easier.


### Key Considerations

- The middle router/switch should support VLAN tagging and handle interface speeds compatible with your circuits.
- Ensure proper configuration for BGP authentication (such as MD5 keys), interface IPs, and VLAN IDs.
- Monitor and maintain route health to guarantee seamless failover and access to both redundant paths.[^3_9][^3_6]
- This approach is supported for both Dedicated and Partner Interconnect configurations with GCP.[^3_4][^3_9]

In summary, inserting a middle router or Layer 2 switch to connect both your Tata router and Google Cloud Router is both feasible and often recommended for flexible, resilient network designs in hybrid and multi-path scenarios.[^3_6][^3_9][^3_4]
<span style="display:none">[^3_1][^3_10][^3_2][^3_3][^3_5][^3_7][^3_8]</span>

<div align="center">⁂</div>

[^3_1]: https://docs.packetfabric.com/cr/add/google/

[^3_2]: https://community.equinix.com/blog/videostutorials/connecting-fabric-cloud-router-to-google-cloud-platform/2591

[^3_3]: https://docs.cloud.google.com/network-connectivity/docs/router/how-to/create-router-vpc-network

[^3_4]: https://cloud.google.com/network-connectivity/docs/router/how-to/create-router-vpc-network

[^3_5]: https://cloud.google.com/network-connectivity/docs/network-connectivity-center/how-to/connect-site-to-cloud

[^3_6]: https://cloud.google.com/network-connectivity/docs/interconnect/how-to/partner/configuring-onprem-routers

[^3_7]: https://docs.cloud.google.com/network-connectivity/docs/router

[^3_8]: https://www.youtube.com/watch?v=DYGRCLbHQo8

[^3_9]: https://cloud.google.com/network-connectivity/docs/interconnect/how-to/dedicated/configuring-onprem-routers

[^3_10]: https://www.cloudskillsboost.google/course_templates/535/video/377240


---

# So can I use cilium to do that actually I want a SD wan kind of stuff so tell me how can I add both cloud router and Tata router to shared router to have load balance as well as failover and which should be reliable and fast

Cilium by itself is not a full SD-WAN platform—it is primarily an open-source networking, security, and observability tool within Kubernetes environments, providing advanced networking (via eBPF) and network policies. You cannot directly use Cilium to serve as the traditional SD-WAN fabric or routing orchestrator to natively bond or aggregate a Google Cloud Router and a Tata router at the WAN or physical network layer.[^4_2]

### SD-WAN for Multi-Path and Load Balancing

To achieve reliable SD-WAN-like behavior with both load balancing and failover between a Google Cloud Router and a Tata router, the recommended approach is:

- Deploy a proper SD-WAN solution (such as Cisco Catalyst SD-WAN, Citrix SD-WAN, Fortinet, Versa, Palo Alto Networks, or VMware) in conjunction with Google Cloud’s Network Connectivity Center (NCC).
- These SD-WAN appliances can be deployed as virtual router/VMs within Google Cloud and at your on-prem location (next to or as the Tata router), connecting both to your shared router/switch infrastructure.[^4_5][^4_7]
- The SD-WAN appliance establishes tunnels or BGP sessions with both your Tata/Equinix routers and the Google Cloud Router, using intelligent policies to load-balance and failover traffic across links.[^4_8][^4_2]


### Integration Details

1. **Middle/Shared Router or Switch:**
Deploy your SD-WAN appliance(s) as the aggregation point—either as a virtual machine (VM) on-prem (physical or virtual) or in Google Cloud.
    - Connect both Google Cloud Router and Tata router to this device (typically using VLAN sub-interfaces).
    - The SD-WAN platform will form BGP or IPSec tunnels to both routers, detecting link quality and performing real-time switching.[^4_6][^4_5]
2. **SD-WAN Control Policy:**
The SD-WAN orchestrator centrally manages routing and failover rules, monitoring quality metrics (latency, jitter, packet loss).
    - Actively load balances normal traffic and instantly fails over in a link-down or performance degradation event.
    - Some solutions can integrate with Cilium in Kubernetes clusters for granular, application-based routing.[^4_2]
3. **Network Reliability and Speed:**
When using a purpose-built SD-WAN platform with cloud orchestration (NCC, Cisco, Fortinet, etc.), reliability is enhanced with automated failover, end-to-end path health checks, and optimized routing, providing both high speed and uptime.[^4_5][^4_6][^4_8]

### Why Not Only Cilium?

- Cilium is excellent for container networking and granular security rules within Kubernetes, but it does not do WAN-level link bonding, path selection, or failover between non-Kubernetes routers.
- Combining Cilium (for cluster networking) with a robust SD-WAN fabric creates a comprehensive, modern network: SD-WAN handles WAN routing, failover, and load balancing; Cilium secures traffic at the application and pod level.[^4_2]


### Recommendation

- Use a tried-and-tested SD-WAN solution on the middle/shared router or as VM appliances at the network edge (on-prem and in GCP).
- Connect both your Google Cloud Router and Tata router into this SD-WAN fabric, and let it manage intelligent load balancing and failover.
- Optionally, leverage Cilium within your Kubernetes clusters for deeper network visibility and policy enforcement, but rely on SD-WAN for WAN path control and resilience.[^4_7][^4_6][^4_5][^4_2]

This setup delivers the fast, reliable, and robust SD-WAN architecture you are aiming for.
<span style="display:none">[^4_1][^4_10][^4_3][^4_4][^4_9]</span>

<div align="center">⁂</div>

[^4_1]: https://www.cisco.com/c/en/us/td/docs/solutions/CVD/SDWAN/Cisco-GCP-Guide.html

[^4_2]: https://www.cncf.io/blog/2025/10/25/connecting-distributed-kubernetes-with-cilium-and-sd-wan-building-an-intelligent-network-fabric/

[^4_3]: https://docs.netscaler.com/en-us/citrix-sd-wan-orchestrator/downloads/citrix-sdwan-with-google-ncc-deployment-guide.pdf

[^4_4]: https://www.cloudskillsboost.google/focuses/71305?parent=catalog

[^4_5]: https://cloud.google.com/blog/products/networking/expanding-sd-wan-reach-of-network-connectivity-center

[^4_6]: https://docs.fortinet.com/document/fortigate-public-cloud/7.6.0/gcp-administration-guide/554824/sd-wan-transit-routing-with-google-network-connectivity-center

[^4_7]: https://cloud.google.com/network-connectivity-center

[^4_8]: https://www.ciscolive.com/c/dam/r/ciscolive/global-event/docs/2022/pdf/BRKENT-2281.pdf

[^4_9]: https://www.cisco.com/c/en/us/td/docs/routers/sdwan/configuration/cloudonramp/ios-xe-17/cloud-onramp-book-xe/cloud-onramp-multi-cloud-google-cloud.html

[^4_10]: https://video.cisco.com/detail/video/6242685516001


---

# Is there any open source reliable and robust router software /SD one available as self hosted to use for this purpose

Yes, there are several **open source router and SD-WAN software solutions** that are robust, reliable, and can be self-hosted for enterprise use. These options allow you to build sophisticated WAN and failover networks similar to commercial SD-WAN, though they may require more manual configuration and expertise.

### Leading Open Source Router/SD-WAN Solutions

- **VyOS:**
VyOS is an enterprise-grade open source router OS supporting advanced dynamic routing (BGP, OSPF), VPNs, policy-based routing, and network automation. It runs on x86, ARM, VMs, and is widely deployed in cloud and data center scenarios for WAN, SD-Branch, and hybrid cloud.[^5_2][^5_3]
- **OPNsense / pfSense:**
Both OPNsense and pfSense are open source firewall/router platforms that support multi-WAN, load balancing, and IPsec/VPN—key features for SD-WAN-like deployments. They offer WebUIs, plugins, and commercial support options, and can be run on physical or virtual appliances.[^5_3][^5_2]
- **AsterNOS-VPP:**
A modern, data-center-grade router OS providing high-speed data plane forwarding, robust BGP/OSPF, HA, dual-stack, IPsec/WireGuard, and mesh traffic scheduling. It receives quarterly updates and is suitable for high-throughput networks.[^5_2]
- **flexiWAN:**
One of the world’s first open source SD-WAN projects, flexiWAN provides modular, cloud-managed SD-WAN that supports dynamic WAN path selection, traffic steering, failover, and customizable apps on top of commodity x86 hardware or VMs. It is built for enterprise and service provider-grade resilience.[^5_5][^5_6]
- **Nante-WAN:**
An open source SD-WAN using Linux, FRRouting, DMVPN, and EVPN. It provides NAT traversal, multipoint encrypted overlays, and is distributed as Docker containers for quick testing or deployment in VM/physical environments.[^5_4]


### Recommendation

For your use case (load balancing, failover between GCP Cloud Router and Tata router, robust and cost-effective self-hosted setup):

- **flexiWAN** is the top open-source SD-WAN solution with active community, modern architecture, and enterprise reliability.[^5_6][^5_5]
- **VyOS** is strongly recommended if you need robust dynamic routing and want to tightly control BGP/IPSec path management at both cloud and on-prem locations.[^5_3][^5_2]
- For firewall-centric SD-WAN with web UI, **OPNsense** and **pfSense** are trusted choices.[^5_2][^5_3]

All these can be deployed as a "shared router/SD-WAN controller" and integrate your Tata and GCP Cloud routers, providing fast failover and load balancing through dynamic routing policies.

These solutions offer a viable, cost-efficient, and feature-rich alternative to expensive commercial SD-WAN appliances while maintaining reliability and speed.[^5_4][^5_5][^5_6][^5_3][^5_2]
<span style="display:none">[^5_1][^5_10][^5_7][^5_8][^5_9]</span>

<div align="center">⁂</div>

[^5_1]: https://www.reddit.com/r/networking/comments/e89gpe/could_one_make_a_vendorneutral_sdwanlike_solution/

[^5_2]: https://cloudswit.ch/blogs/7-best-open-source-router-os-software/

[^5_3]: https://www.comparitech.com/net-admin/open-source-router-os-software/

[^5_4]: https://github.com/upa/nante-wan

[^5_5]: https://flexiwan.com

[^5_6]: https://flexiwan.com/sd-wan-open-source/

[^5_7]: https://www.reddit.com/r/networking/comments/kt31j5/sdwan_replacement_that_is_free/

[^5_8]: https://datacipher.com/10-top-sd-wan-solutions-for-enterprises/

[^5_9]: https://github.com/topics/sd-wan

[^5_10]: https://www.youtube.com/watch?v=XVKY8hGXGiw


---

# Is there any cloud sdwan available in gcp service which I can use

Google Cloud Platform offers a cloud SD-WAN service integration primarily through its **Network Connectivity Center (NCC)**, which is designed as a centralized hub for managing and connecting enterprise networks including SD-WAN appliances.[^6_3]

### Key Cloud SD-WAN Options on GCP:

- **Cisco SD-WAN Cloud Hub with Google Cloud:**
Cisco's SD-WAN platform integrates deeply with Google Cloud allowing site-to-cloud and site-to-site connectivity using Cisco Catalyst 8000v virtual routers deployed in GCP. This setup enables automated provisioning, global scale routing over Google’s backbone, and policy-driven traffic management. It supports active-active load balancing and failover scenarios seamlessly within Google Cloud infrastructure.[^6_1][^6_2][^6_10]
- **Network Connectivity Center (NCC) + SD-WAN Appliances:**
NCC acts as a central hub in GCP to which you can attach third-party SD-WAN solutions (Cisco, Fortinet, Palo Alto Networks, Versa, VMware, Silver Peak, etc.). These appliances run as VMs inside GCP and integrate with your on-prem SD-WAN or edge routers, simplifying hybrid cloud management, enabling global routing, and leveraging Google’s high-performance backbone.[^6_4][^6_5][^6_3]
- **Silver Peak (part of Aruba, a Hewlett Packard Enterprise company):**
Available on the Google Cloud Marketplace, Silver Peak’s Unity EdgeConnect SD-WAN can be deployed directly in Google Cloud as a VM appliance, offering WAN optimization, dynamic path control for active-active scenarios, and seamless connectivity between on-prem and cloud workloads.[^6_5]


### Summary

Google Cloud itself does not provide a built-in proprietary SD-WAN product but enables integration and deployment of leading SD-WAN vendors on its cloud platform using Network Connectivity Center as a control point. The best option is to use these cloud SD-WAN solutions (especially Cisco SD-WAN Cloud Hub or Silver Peak Unity EdgeConnect) for a reliable, scalable, and automated SD-WAN experience fully integrated with Google Cloud.[^6_1][^6_3][^6_5]

This approach allows you to deploy SD-WAN in the cloud, connect it to your on-prem Tata and Google Cloud Routers, and achieve efficient load balancing and failover with minimal manual overhead.
<span style="display:none">[^6_6][^6_7][^6_8][^6_9]</span>

<div align="center">⁂</div>

[^6_1]: https://www.cisco.com/c/en/us/solutions/collateral/enterprise-networks/sd-wan/at-a-glance-c45-2362352.html

[^6_2]: https://www.cisco.com/c/en/us/td/docs/solutions/CVD/SDWAN/Cisco-GCP-Guide.html

[^6_3]: https://cloud.google.com/network-connectivity-center

[^6_4]: https://cloud.google.com/blog/products/networking/expanding-sd-wan-reach-of-network-connectivity-center

[^6_5]: https://www.silver-peak.com/company/tech-partners/cloud/google-cloud

[^6_6]: https://codelabs.developers.google.com/ncc-3pnva-site-to-cloud

[^6_7]: https://www.cloudskillsboost.google/focuses/14867?parent=catalog\&qlcampaign=77-10TGCP-918

[^6_8]: https://cloud.google.com/products/networking

[^6_9]: https://docs.cloud.google.com/network-connectivity/docs/wan-partners

[^6_10]: https://video.cisco.com/detail/video/6242685516001


---

# Now can you give me final architectural design and the ASCII diagram for my active active setup using Google NCC

Here is a final architectural design and an ASCII diagram for your active-active multi-region setup using Google Cloud Network Connectivity Center (NCC) integrating your Tata router and Google Cloud Router with SD-WAN capabilities for load balancing and failover.

## Architectural Design Summary

- Use **Google Network Connectivity Center (NCC)** as the central hub/router in Google Cloud. NCC acts as a managed transit hub leveraging Google’s global backbone.
- Deploy your **SD-WAN appliance/router VMs** (e.g., Cisco SD-WAN Cloud Gateway, Versa, or any supported appliance) in GCP VPCs as spokes attached to NCC.
- Connect your **Tata on-prem router** and **Google Cloud Router** as separate spoke connections into NCC through respective site-to-cloud connections (Tata’s IPsec VPN/MPLS and Equinix Partner Interconnect respectively).
- The SD-WAN appliances establish **BGP peering** with both your Tata router and Google Cloud Router, enabling dynamic routing, real-time health monitoring, and fast failover.
- NCC ensures traffic between on-prem sites, SD-WAN appliances, and GCP workloads is routed via the optimal active link, using Google’s private global network for low latency and high resilience.
- This setup provides **active-active multi-path routing**, leveraging cloud global bandwidth and built-in failover mechanisms.


## ASCII Diagram

```
         +------------------+                  +-------------------+
         |  Tata On-Premise |                  |  Equinix Partner  |
         |    Router (VPN)  |                  | Interconnect to   |
         |                  |                  | Google Cloud Router|
         +---------+--------+                  +--------+----------+
                   |                                    |
                   |                                    |
                   |      Site-to-Cloud connections     |
                   |                                    |
         +---------v------------------------------------v---------+
         |                       Google Cloud NCC Hub             |
         |        (Network Connectivity Center - Managed Router)  |
         |                                                          |
         |   +----------------+           +------------------+     |
         |   | SD-WAN Router  |<----------| Google Cloud     |     |
         |   | Appliance VM   |           | Router (Cloud RI)|     |
         |   +----------------+           +------------------+     |
         |          |                                               |
         |          |    Dynamic BGP Routing & Load Balancing      |
         +----------+-----------------------------------------------+
                    |
                    | Google Cloud Global Backbone & VPC Networks
                    |
          +------------------+          +------------------+
          |   Multi-Region   |          |   Multi-Region   |
          |   GCP Workloads  |          |   GCP Workloads  |
          +------------------+          +------------------+
```


## Key Features of this Architecture

- **Redundant WAN links:** Tata VPN/MPLS and Equinix Partner Interconnect provide independent physical paths.
- **Centralized routing and policy:** Google NCC hub integrates routing from both paths and SD-WAN appliances.
- **Dynamic failover and load balancing:** SD-WAN appliances and BGP routing dynamically distribute traffic based on link health.
- **Global backbone utilization:** Traffic flows over Google’s premium global network for high performance.
- **Multi-region resilience:** Workloads in GCP across regions maintain connectivity without single points of failure.

This design ensures active-active resilience with automated failover, optimized routing, and cost-effective hybrid cloud connectivity using Google NCC with SD-WAN integration.[^7_1][^7_4][^7_6][^7_11]

If you want, further implementation details on configuration or vendor-specific SD-WAN integration can be provided.
<span style="display:none">[^7_10][^7_2][^7_3][^7_5][^7_7][^7_8][^7_9]</span>

<div align="center">⁂</div>

[^7_1]: https://www.cisco.com/c/en/us/td/docs/solutions/CVD/SDWAN/Cisco-GCP-Guide.html

[^7_2]: https://just4cloud.com/advanced-networking-topologies-google-cloud/

[^7_3]: https://community.aviatrix.com/tech-zone-14/aviatrix-google-cloud-networking-connectivity-center-ncc-integrated-solution-541

[^7_4]: https://cloud.google.com/architecture/network-hybrid-multicloud

[^7_5]: https://www.youtube.com/watch?v=Cmb58HnlpIg

[^7_6]: https://docs.fortinet.com/document/fortigate-public-cloud/7.6.0/gcp-administration-guide/554824/sd-wan-transit-routing-with-google-network-connectivity-center

[^7_7]: https://docs.fortinet.com/document/fortigate-public-cloud/7.4.0/gcp-administration-guide/554824/sd-wan-transit-routing-with-google-network-connectivity-center

[^7_8]: https://versa-networks.com/documents/solution-briefs/versa-sase-and-google-network-connectivity-center.pdf

[^7_9]: https://www.youtube.com/watch?v=BGB0ojLA22M

[^7_10]: https://cloud.google.com/products/networking

[^7_11]: https://cloud.google.com/network-connectivity-center


---

# How should I configure with Tata on prem to CCN

To configure your Tata on-premises router to connect with Google Cloud Network Connectivity Center (NCC), follow these steps, focusing on establishing a secure IPsec VPN connection and dynamic routing using BGP for active-active failover and load balancing:

### 1. Establish IPsec VPN Tunnels

- Set up a pair of IPsec VPN tunnels from your Tata router to the Google Cloud VPN gateway associated with NCC.
- For higher availability, configure two tunnels in an active-passive or active-active state.
- Use strong encryption protocols (IKEv2, AES-256) and pre-shared keys or certificates as per your security policy.[^8_1]


### 2. Create and Configure Cloud Router in GCP

- Create a Cloud Router resource in the same region as your VPN gateway within Google Cloud.
- Assign an Autonomous System Number (ASN) for BGP peering; ensure it does not conflict with Tata's ASN.
- Link the Cloud Router to your VPN gateway.


### 3. Configure BGP Peering

- Establish BGP sessions between the Tata router and the Cloud Router over the IPsec tunnels.
- Advertise your on-premises network prefixes from Tata, and receive GCP subnet routes dynamically.
- Tune BGP settings such as keepalive timers, hold time, and route advertisement policies for optimal failover and load balancing.[^8_2][^8_1]


### 4. Integrate with Network Connectivity Center

- Add your Tata network as a hybrid spoke in NCC.
- Attach the VPN tunnels and the Cloud Router to the NCC hub.
- Enable route exchange between the Tata on-prem network, GCP VPCs, and other connected spoke networks.
- NCC will automatically manage routing, failover, and load balancing across multiple spokes including your Equinix Partner Interconnect.[^8_5]


### 5. Testing and Monitoring

- Test connectivity by sending traffic across both paths.
- Use Google Cloud Console and Tata router logs to monitor tunnel status, BGP session health, and failover operations.
- Implement alerting for tunnel or route failures.

This configuration provides a resilient, redundant, and dynamically routed link from your Tata on-premises router through IPsec into Google’s Cloud NCC, supporting active-active failover and efficient traffic distribution.[^8_1][^8_2][^8_5]

If desired, detailed CLI or console commands for Tata router or Google Cloud components can be provided.
<span style="display:none">[^8_10][^8_3][^8_4][^8_6][^8_7][^8_8][^8_9]</span>

<div align="center">⁂</div>

[^8_1]: https://www.cloudskillsboost.google/focuses/18539?parent=catalog

[^8_2]: https://cloud.google.com/network-connectivity/docs/router/how-to/create-router-vpc-network

[^8_3]: https://cloud.google.com/network-connectivity/docs/network-connectivity-center/how-to/creating-router-appliances

[^8_4]: https://docs.cloud.google.com/network-connectivity/docs/network-connectivity-center/concepts/ra-overview

[^8_5]: https://docs.cloud.google.com/network-connectivity/docs/network-connectivity-center/concepts/overview

[^8_6]: https://www.youtube.com/watch?v=x6P3NwiPmP4

[^8_7]: https://cloud.google.com/products/networking

[^8_8]: https://www.tatatelebusiness.com/articles/mpls-vpn/

[^8_9]: https://partner.cloudskillsboost.google/paths/1848/course_templates/21/video/534316?locale=it

[^8_10]: https://partner.cloudskillsboost.google/paths/79/course_templates/1145/video/575456?locale=it
