BGP (Border Gateway Protocol) Overview
==========================================

BGP is the routing protocol that makes the Internet work. It's used between 
Autonomous Systems (AS) - large networks like ISPs, cloud providers, and 
enterprises - to exchange routing information and determine the best paths 
for traffic across the global Internet.

Key Concepts:
- Autonomous System (AS): A network under single administrative control
- AS Number (ASN): Unique identifier for each AS (e.g., AS65001)
- BGP Speaker: Router that runs BGP protocol
- BGP Session: TCP connection between two BGP speakers


BGP Session Establishment & Operation
====================================

Step 1: TCP Connection (Port 179)
Router A ←────────────────────────→ Router B
        TCP SYN (port 179)
        ←────────────────────────
        TCP SYN-ACK
        ────────────────────────→
        TCP ACK

Step 2: BGP Session States
┌─────────────────────────────────────────────────────────┐
│ BGP Finite State Machine                                │
├─────────────────────────────────────────────────────────┤
│ IDLE → CONNECT → OPEN SENT → OPEN CONFIRM → ESTABLISHED │
└─────────────────────────────────────────────────────────┘

Step 3: Route Advertisement
Router A                           Router B
   │                                 │
   │ ─── BGP UPDATE (routes) ──────→ │
   │ ←─── BGP UPDATE (routes) ────── │
   │                                 │
   │ ─── BGP KEEPALIVE ───────────→  │
   │ ←─── BGP KEEPALIVE ──────────── │


BGP Network Topology Example
============================

Internet Service Providers (ISPs) and BGP Peering:

    ┌─────────────┐         ┌─────────────┐
    │   AS 100    │         │   AS 200    │
    │ (ISP Alpha) │◄───────►│ (ISP Beta)  │
    │             │  iBGP   │             │
    └──────┬──────┘         └──────┬──────┘
           │                       │
           │ eBGP                  │ eBGP
           │                       │
    ┌──────▼──────┐         ┌──────▼──────┐
    │   AS 300    │         │   AS 400    │
    │(Enterprise A)│        │(Enterprise B)│
    └─────────────┘         └─────────────┘

Legend:
- eBGP: External BGP (between different AS)
- iBGP: Internal BGP (within same AS)
- Each line represents a BGP peering session


BGP Route Selection Process
==========================

When multiple paths exist to a destination:

┌──────────────────────────────────────────────────┐
│ BGP Best Path Selection Algorithm                │
├──────────────────────────────────────────────────┤
│ 1. Highest LOCAL_PREF                           │
│ 2. Shortest AS_PATH                              │
│ 3. Lowest ORIGIN (IGP < EGP < Incomplete)       │
│ 4. Lowest MED (Multi-Exit Discriminator)        │
│ 5. eBGP over iBGP                                │
│ 6. Lowest IGP cost to BGP next hop              │
│ 7. Lowest Router ID                              │
└──────────────────────────────────────────────────┘


NATS (Network Address Translation System) Overview
==================================================

NATS is a lightweight, high-performance messaging system for microservices,
IoT, and cloud native systems. It provides publish-subscribe, request-reply,
and queueing patterns.

Core Components:
- NATS Server: Message broker/router
- NATS Client: Publishers and subscribers
- Subjects: Message routing addresses (like topics)


NATS Architecture Diagram
=========================

Simple NATS Cluster:

    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
    │ NATS Node 1 │────│ NATS Node 2 │────│ NATS Node 3 │
    │   :4222     │    │   :4222     │    │   :4222     │
    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
           │                  │                  │
           └──────────────────┼──────────────────┘
                              │
            ┌─────────────────────────────────┐
            │         Client Zone             │
            └─────────────────────────────────┘
                              │
         ┌────────────┬───────┼───────┬────────────┐
         │            │       │       │            │
    ┌────▼───┐   ┌───▼───┐   │   ┌───▼───┐   ┌────▼───┐
    │Pub/Sub │   │Request│   │   │Queue  │   │Stream  │
    │Client  │   │Reply  │   │   │Group  │   │Client  │
    │        │   │Client │   │   │Client │   │        │
    └────────┘   └───────┘   │   └───────┘   └────────┘
                             │
                        ┌────▼───┐
                        │Gateway │
                        │        │
                        └────────┘


NATS Message Flow Examples
==========================

1. Publish-Subscribe Pattern:
   
   Publisher                NATS Server              Subscriber A
      │                         │                        │
      │ ──PUB weather.temp.nyc──→                       │
      │                         │ ───weather.temp.nyc──→│
      │                         │                        │
                                 │ ───weather.temp.nyc──→ Subscriber B


2. Request-Reply Pattern:

   Client                   NATS Server              Service
      │                         │                      │
      │ ──REQ user.lookup────────→                     │
      │                         │ ──user.lookup──────→ │
      │                         │ ←─────reply─────────  │
      │ ←──────reply─────────────                      │


3. Queue Groups (Load Balancing):

   Publisher               NATS Server           Queue Group "workers"
      │                        │                     │
      │ ──PUB task.process─────→                     │
      │                        │ ──→ Worker 1        │
      │ ──PUB task.process─────→                     │
      │                        │ ──→ Worker 2        │
      │ ──PUB task.process─────→                     │
      │                        │ ──→ Worker 3        │


NATS Subject Hierarchy
=====================

Subjects use dot notation for hierarchical organization:

Root Subject: "com.company"
├── com.company.orders
│   ├── com.company.orders.created
│   ├── com.company.orders.updated
│   └── com.company.orders.cancelled
├── com.company.users
│   ├── com.company.users.login
│   └── com.company.users.logout
└── com.company.inventory
    ├── com.company.inventory.low
    └── com.company.inventory.restock

Wildcards:
- "*" matches single token: "com.company.*" 
- ">" matches multiple tokens: "com.company.orders.>"


NATS vs Traditional Message Queues
==================================

Traditional Queue:        NATS:
┌─────────────┐          ┌─────────────┐
│ Producer    │          │ Publisher   │
└─────┬───────┘          └─────┬───────┘
      │                        │
      ▼                        ▼
┌─────────────┐          ┌─────────────┐
│    Queue    │          │NATS Subject │
│ [msg][msg]  │          │  (topic)    │
│ [msg][msg]  │          └─────┬───────┘
└─────┬───────┘                │
      │                        ▼
      ▼                 ┌──────────────┐
┌─────────────┐         │ Subscribers  │
│ Consumer    │         │ (multiple)   │
└─────────────┘         └──────────────┘

Key Differences:
- NATS: Fire-and-forget, in-memory by default
- Traditional: Persistent, guaranteed delivery
- NATS: Extremely fast, low latency
- Traditional: More reliability features, slower
