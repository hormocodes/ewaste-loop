# E-Waste Loop 🔄♻️

A blockchain-based supply chain tracker for electronic waste management on the Stacks blockchain, enabling transparent tracking of devices through collection, dismantling, material recovery, and remanufacturing stages.

## 📋 Table of Contents

- [Overview](#overview)
- [Why E-Waste Loop?](#why-e-waste-loop)
- [Features](#features)
- [Contract Architecture](#contract-architecture)
- [Getting Started](#getting-started)
- [Usage Guide](#usage-guide)
- [API Reference](#api-reference)
- [Example Workflow](#example-workflow)
- [Testing](#testing)
- [Deployment](#deployment)
- [Security](#security)
- [Contributing](#contributing)

## 🌍 Overview

**E-Waste Loop** is a Clarity smart contract that creates transparent, immutable records for electronic waste moving through the circular economy. It tracks devices from collection through remanufacturing, ensuring accountability and enabling data-driven sustainability initiatives.

### The Problem

- 50+ million tons of e-waste generated annually
- Only 17.4% formally recycled
- Lack of transparency in e-waste supply chains
- Difficulty tracking material recovery and reuse
- Limited accountability in the recycling process

### The Solution

E-Waste Loop provides:
- **Transparent tracking** of devices through their entire lifecycle
- **Immutable records** on the Stacks blockchain
- **Authorization system** for verified participants
- **Material recovery tracking** for circular economy metrics
- **Compliance support** for environmental regulations

## 🎯 Why E-Waste Loop?

### For Collectors
- Register collected devices with full traceability
- Build trust with customers through transparency
- Demonstrate compliance with regulations

### For Recyclers
- Document dismantling and material recovery
- Prove value extraction from e-waste
- Access to verified supply chain data

### For Manufacturers
- Track use of recycled materials
- Meet sustainability goals with verifiable data
- Support circular economy initiatives

### For Regulators
- Real-time visibility into e-waste flows
- Immutable compliance records
- Data for policy development

## ✨ Features

### Core Functionality
- ✅ **Device Registration** - Record e-waste at collection point
- ✅ **Lifecycle Tracking** - Monitor devices through 4 stages
- ✅ **Material Recovery** - Track extracted materials (copper, gold, silver, plastic)
- ✅ **Authorization System** - Role-based access control
- ✅ **Transfer Management** - Secure custody transfers
- ✅ **Complete History** - Immutable audit trail

### Lifecycle Stages

1. **Collection** 📦
   - Initial e-waste registration
   - Device type and manufacturer details
   - Serial number tracking
   - Collection location

2. **Dismantling** 🔧
   - Disassembly documentation
   - Component separation
   - Location tracking

3. **Material Recovery** ⚗️
   - Extracted material quantities
   - Material types (copper, gold, silver, plastic, other)
   - Recovery facility details

4. **Remanufacturing** 🏭
   - New product creation
   - Material reuse documentation
   - Circular economy closure

## 🏗️ Contract Architecture

### Data Structures

#### Devices Map
```clarity
{
  device-id: uint,
  device-type: string,
  manufacturer: string,
  serial-number: string,
  current-stage: uint,
  current-holder: principal,
  created-at: uint
}
```

#### Device History Map
```clarity
{
  device-id: uint,
  stage: uint,
  holder: principal,
  location: string,
  timestamp: uint,
  notes: string
}
```

#### Materials Recovered Map
```clarity
{
  device-id: uint,
  copper-kg: uint,
  gold-g: uint,
  silver-g: uint,
  plastic-kg: uint,
  other-materials: string,
  recovery-date: uint
}
```

#### Authorized Participants Map
```clarity
{
  participant: principal,
  role: string,
  authorized: bool
}
```

### Constants

**Lifecycle Stages:**
- `stage-collected` = 1
- `stage-dismantled` = 2
- `stage-material-recovered` = 3
- `stage-remanufactured` = 4

**Error Codes:**
- `err-owner-only` (u100) - Operation restricted to contract owner
- `err-not-found` (u101) - Device not found
- `err-unauthorized` (u102) - Participant not authorized
- `err-invalid-stage` (u103) - Invalid lifecycle stage transition
- `err-already-exists` (u104) - Record already exists

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development tool
- Stacks wallet (Leather, Xverse, or Hiro)
- Basic understanding of Clarity smart contracts

### Installation

1. **Clone or download the contract:**
```bash
mkdir ewaste-loop
cd ewaste-loop
```

2. **Initialize Clarinet project:**
```bash
clarinet new ewaste-loop-project
cd ewaste-loop-project
```

3. **Add the contract:**
```bash
# Copy ewaste-loop.clar to contracts/
cp path/to/ewaste-loop.clar contracts/
```

4. **Verify the contract:**
```bash
clarinet check
```

## 📖 Usage Guide

### Step 1: Deploy the Contract

```bash
# Test deployment
clarinet integrate

# Mainnet deployment (using Clarinet or Hiro Platform)
clarinet deploy --network mainnet
```

### Step 2: Authorize Participants

Only the contract owner can authorize participants:

```clarity
;; Authorize a collector
(contract-call? .ewaste-loop authorize-participant 
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    "Collector"
)

;; Authorize a dismantler
(contract-call? .ewaste-loop authorize-participant 
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
    "Dismantler"
)

;; Authorize a recovery facility
(contract-call? .ewaste-loop authorize-participant 
    'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC
    "Recovery Facility"
)

;; Authorize a manufacturer
(contract-call? .ewaste-loop authorize-participant 
    'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB
    "Manufacturer"
)
```

### Step 3: Register Devices

Authorized collectors register e-waste:

```clarity
(contract-call? .ewaste-loop register-device
    "Laptop"                              ;; device-type
    "Dell"                                ;; manufacturer
    "SN123456789"                         ;; serial-number
    "Manhattan Collection Center, NYC"    ;; location
    "Dell Latitude E7450, working"        ;; notes
)
;; Returns: (ok u1) - device ID
```

### Step 4: Progress Through Lifecycle

#### Dismantling
```clarity
(contract-call? .ewaste-loop dismantle-device
    u1                                    ;; device-id
    "Brooklyn Dismantling Facility"       ;; location
    "Disassembled into components"        ;; notes
)
```

#### Material Recovery
```clarity
(contract-call? .ewaste-loop recover-materials
    u1                                    ;; device-id
    u2                                    ;; copper in kg
    u15                                   ;; gold in grams
    u50                                   ;; silver in grams
    u5                                    ;; plastic in kg
    "aluminum-3kg, rare-earths-100g"      ;; other materials
    "New Jersey Recovery Plant"           ;; location
    "High-grade materials extracted"      ;; notes
)
```

#### Remanufacturing
```clarity
(contract-call? .ewaste-loop remanufacture-device
    u1                                    ;; device-id
    "California Manufacturing Hub"        ;; location
    "Materials used in new laptops"       ;; notes
)
```

### Step 5: Query Information

```clarity
;; Get device information
(contract-call? .ewaste-loop get-device u1)

;; Get stage history
(contract-call? .ewaste-loop get-device-stage-history u1 u2)

;; Get materials recovered
(contract-call? .ewaste-loop get-materials-recovered u1)

;; Check authorization
(contract-call? .ewaste-loop is-authorized 
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
)

;; Get total devices registered
(contract-call? .ewaste-loop get-device-counter)
```

## 📚 API Reference

### Public Functions

#### `authorize-participant`
Authorizes a new supply chain participant (owner only).

**Parameters:**
- `participant: principal` - Wallet address
- `role: (string-ascii 30)` - Role description

**Returns:** `(response bool uint)`

**Example:**
```clarity
(contract-call? .ewaste-loop authorize-participant 
    'ST1PARTICIPANT123 
    "Collector"
)
```

---

#### `revoke-authorization`
Revokes participant authorization (owner only).

**Parameters:**
- `participant: principal` - Wallet address to revoke

**Returns:** `(response bool uint)`

---

#### `register-device`
Registers a new e-waste device at collection stage.

**Parameters:**
- `device-type: (string-ascii 50)` - Type (laptop, phone, etc.)
- `manufacturer: (string-ascii 50)` - Brand name
- `serial-number: (string-ascii 100)` - Unique identifier
- `location: (string-ascii 100)` - Collection point
- `notes: (string-ascii 200)` - Additional information

**Returns:** `(response uint uint)` - Device ID

**Requirements:** Caller must be authorized

---

#### `dismantle-device`
Updates device to dismantling stage.

**Parameters:**
- `device-id: uint` - Device identifier
- `location: (string-ascii 100)` - Facility location
- `notes: (string-ascii 200)` - Dismantling details

**Returns:** `(response bool uint)`

**Requirements:** 
- Caller must be authorized
- Device must be in collection stage

---

#### `recover-materials`
Records material recovery and updates stage.

**Parameters:**
- `device-id: uint` - Device identifier
- `copper-kg: uint` - Copper in kilograms
- `gold-g: uint` - Gold in grams
- `silver-g: uint` - Silver in grams
- `plastic-kg: uint` - Plastic in kilograms
- `other-materials: (string-ascii 200)` - Other materials description
- `location: (string-ascii 100)` - Recovery facility
- `notes: (string-ascii 200)` - Recovery details

**Returns:** `(response bool uint)`

**Requirements:**
- Caller must be authorized
- Device must be in dismantling stage

---

#### `remanufacture-device`
Records remanufacturing completion.

**Parameters:**
- `device-id: uint` - Device identifier
- `location: (string-ascii 100)` - Manufacturing facility
- `notes: (string-ascii 200)` - Manufacturing details

**Returns:** `(response bool uint)`

**Requirements:**
- Caller must be authorized
- Device must be in material recovery stage

---

#### `transfer-device`
Transfers device custody between authorized participants.

**Parameters:**
- `device-id: uint` - Device identifier
- `new-holder: principal` - New holder's address

**Returns:** `(response bool uint)`

**Requirements:**
- Caller must be current holder
- Both parties must be authorized

---

### Read-Only Functions

#### `get-device`
Retrieves complete device information.

**Parameters:**
- `device-id: uint`

**Returns:** `(optional device-record)`

---

#### `get-device-stage-history`
Gets history for a specific lifecycle stage.

**Parameters:**
- `device-id: uint`
- `stage: uint` - Stage number (1-4)

**Returns:** `(optional history-record)`

---

#### `get-materials-recovered`
Retrieves materials extracted from device.

**Parameters:**
- `device-id: uint`

**Returns:** `(optional materials-record)`

---

#### `is-authorized`
Checks if address is authorized.

**Parameters:**
- `participant: principal`

**Returns:** `bool`

---

#### `get-device-counter`
Returns total devices registered.

**Returns:** `(response uint uint)`

## 🔄 Example Workflow

### Complete Device Lifecycle

```clarity
;; 1. Contract owner authorizes all participants
(contract-call? .ewaste-loop authorize-participant 'ST1COLLECTOR "Collector")
(contract-call? .ewaste-loop authorize-participant 'ST1DISMANTLER "Dismantler")
(contract-call? .ewaste-loop authorize-participant 'ST1RECOVERY "Recovery")
(contract-call? .ewaste-loop authorize-participant 'ST1MANUFACTURER "Manufacturer")

;; 2. Collector registers device
(as-contract
  (contract-call? .ewaste-loop register-device
    "Smartphone"
    "Apple"
    "IMEI-987654321"
    "San Francisco Collection Center"
    "iPhone 13, cracked screen"
  )
)
;; Returns: (ok u1)

;; 3. Transfer to dismantler
(as-contract
  (contract-call? .ewaste-loop transfer-device u1 'ST1DISMANTLER)
)

;; 4. Dismantler processes device
(as-contract
  (contract-call? .ewaste-loop dismantle-device
    u1
    "Oakland Dismantling Facility"
    "Screen, battery, and components separated"
  )
)

;; 5. Transfer to recovery facility
(as-contract
  (contract-call? .ewaste-loop transfer-device u1 'ST1RECOVERY)
)

;; 6. Recovery facility extracts materials
(as-contract
  (contract-call? .ewaste-loop recover-materials
    u1
    u0    ;; copper: 0kg
    u3    ;; gold: 3g
    u10   ;; silver: 10g
    u1    ;; plastic: 1kg
    "lithium-battery-25g, rare-earth-magnets-5g"
    "San Jose Recovery Plant"
    "All recyclable materials extracted"
  )
)

;; 7. Transfer to manufacturer
(as-contract
  (contract-call? .ewaste-loop transfer-device u1 'ST1MANUFACTURER)
)

;; 8. Manufacturer creates new products
(as-contract
  (contract-call? .ewaste-loop remanufacture-device
    u1
    "Fremont Manufacturing Plant"
    "Recovered materials used in new smartphone production"
  )
)

;; 9. Query complete history
(contract-call? .ewaste-loop get-device u1)
(contract-call? .ewaste-loop get-device-stage-history u1 u1)
(contract-call? .ewaste-loop get-device-stage-history u1 u2)
(contract-call? .ewaste-loop get-device-stage-history u1 u3)
(contract-call? .ewaste-loop get-device-stage-history u1 u4)
(contract-call? .ewaste-loop get-materials-recovered u1)
```

## 🧪 Testing

### Using Clarinet Console

```bash
clarinet console
```

### Test Script

```clarity
;; Load test file
::load_script test-ewaste-loop.clar

;; Or run individual tests
(contract-call? .ewaste-loop authorize-participant tx-sender "Collector")
(contract-call? .ewaste-loop register-device "Laptop" "HP" "SN001" "NYC" "Test device")
(contract-call? .ewaste-loop get-device u1)
```

### Unit Tests

Create `tests/ewaste-loop_test.ts`:

```typescript
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can register device as authorized participant",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const collector = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('ewaste-loop', 'authorize-participant', 
                [types.principal(collector.address), types.ascii("Collector")], 
                deployer.address),
            Tx.contractCall('ewaste-loop', 'register-device',
                [
                    types.ascii("Laptop"),
                    types.ascii("Dell"),
                    types.ascii("SN123"),
                    types.ascii("NYC"),
                    types.ascii("Test device")
                ],
                collector.address)
        ]);
        
        block.receipts[1].result.expectOk().expectUint(1);
    },
});
```

## 🚢 Deployment

### Testnet Deployment

```bash
# Configure Clarinet.toml for testnet
[network]
name = "testnet"

# Deploy
clarinet deployments apply --testnet
```

### Mainnet Deployment

```bash
# Configure for mainnet
[network]
name = "mainnet"

# Deploy
clarinet deployments apply --mainnet
```

### Post-Deployment Steps

1. **Verify Contract**
   - Check on Stacks Explorer
   - Verify source code

2. **Authorize Initial Participants**
   ```clarity
   (contract-call? 'DEPLOYER.ewaste-loop authorize-participant 
       'ST1FIRST-PARTICIPANT "Collector")
   ```

3. **Document Contract Address**
   - Share with stakeholders
   - Update frontend configuration

## 🔒 Security

### Access Control

- **Owner-Only Functions:** Authorization management restricted to deployer
- **Participant Authorization:** All lifecycle functions require authorization
- **Stage Progression:** Devices must progress through stages in order
- **Transfer Restrictions:** Only current holder can transfer device

### Best Practices

1. **Verify Participants:** Thoroughly vet organizations before authorization
2. **Monitor Transactions:** Track all contract interactions
3. **Secure Private Keys:** Use hardware wallets for contract owner
4. **Regular Audits:** Review participant activities periodically
5. **Backup Data:** Maintain off-chain records as backup

### Known Limitations

- Stage transitions are one-way only
- Cannot delete or edit historical records
- String lengths are limited (see constants)
- No built-in dispute resolution mechanism

## 🌟 Use Cases

### E-Waste Collection Services
Track devices from customer drop-off through final disposition

### Electronic Recycling Facilities
Document material recovery and demonstrate value extraction

### Manufacturers with Take-Back Programs
Close the loop on product lifecycles with verifiable data

### Regulatory Compliance
Provide immutable records for environmental reporting

### Carbon Credit Programs
Track and verify e-waste recycling for credit generation

### Research and Analytics
Aggregate data on e-waste flows and material recovery rates

## 🗺️ Roadmap

### Phase 1: Core Functionality ✅
- Device registration and tracking
- Lifecycle stage management
- Material recovery tracking
- Authorization system

### Phase 2: Enhanced Features (Planned)
- NFT certificates for recycled devices
- Carbon credit integration
- Multi-signature approvals
- IoT device integration

### Phase 3: Ecosystem Integration (Future)
- Frontend dashboard
- Mobile applications
- API for third-party integrations
- Analytics and reporting tools

### Phase 4: Advanced Features (Future)
- Incentive mechanisms (token rewards)
- Predictive analytics
- Cross-chain compatibility
- Automated compliance reporting

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the Repository**
2. **Create Feature Branch:** `git checkout -b feature/amazing-feature`
3. **Commit Changes:** `git commit -m 'Add amazing feature'`
4. **Push to Branch:** `git push origin feature/amazing-feature`
5. **Open Pull Request**

### Development Guidelines

- Follow Clarity best practices
- Add tests for new features
- Update documentation
- Maintain backwards compatibility where possible

## 🙏 Acknowledgments

- Stacks blockchain community
- Circular economy advocates
- E-waste recycling industry partners
- Open source contributors

## 📊 Statistics

Track global impact:
- Total devices tracked: Query `get-device-counter`
- Materials recovered: Aggregate `materials-recovered` map
- Circular economy closure rate: % reaching remanufacturing stage

---

**Built for a sustainable future** 🌱

*E-Waste Loop - Closing the loop on electronic waste, one device at a time.*