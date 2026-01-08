# Blockchain-based Electronic Device Rental Application

This repository contains a decentralised rental platform for electronic devices, built on top of the Ethereum blockchain.  
It was originally developed as my MSc Computer Science dissertation project, *“A Block-chain Based Electronic Device Rental Application”*, at the University of Southampton (2020). 

The goal is to show how blockchain and smart contracts can improve traditional rental systems by reducing dependence on intermediaries, increasing transparency, and providing secure, trustless payments between owners and renters.

## 🎥 Demo

A demo video of the application is available here:  
[Demo video (One Drive)](https://1drv.ms/v/c/d64c9cb957077188/IQBF0pXtjFDPTLNU14_2N_NaATT88Cd8k5hfDe_x9I6bLlI?e=jJA7mA)

---

## 🎯 Project Overview

Traditional online rental platforms (e.g., sharing-economy services) typically rely on a central company that:

- takes a relatively high commission,
- controls all the transaction records and agreements,
- requires users to trust the platform with their data, money, and privacy.

This project proposes a **decentralised electronic device rental system** that:

- runs on Ethereum without a central authority,
- manages rental agreements via smart contracts,
- locks rent and deposit in the contract to protect both parties,
- records the workflow on-chain for auditability and transparency. 

Example devices include laptops, game consoles, and other consumer electronics.

---

## ✨ Main Features

**For owners**

- Register rentable electronic devices on-chain (model, acquisition year, daily rent, required deposit, owner address).
- Approve completion of the tenancy and set deposit deductions.
- Approve or reject cancellation requests from renters. 

**For renters**

- Browse listed devices and view non-sensitive information via the web UI.
- Specify lease term and initiate a rental by paying rent + deposit to the smart contract.
- Complete the tenancy and receive deposit (minus any approved deduction) back from the contract.
- Request cancellation if the device cannot be accessed/used, and get a refund when approved. 

**System behaviour**

- Rent and deposit are sent from the renter to the contract at the start of tenancy.
- During tenancy, neither party can directly access the locked funds.
- On successful completion, the owner receives total rent and the renter gets remaining deposit.
- On approved cancellation, the renter receives a full refund. 

---

## 🧱 Architecture & Components

The application follows a typical Ethereum DApp architecture: 

- **Smart contracts (Solidity)**  
  - Main rental contract implementing the business logic.
  - A Solidity library (`DeviceLib`) defining the device data structure and related fields (model, year, rent, deposit, availability flags, etc.). 

- **External scripts (JavaScript + Web3.js)**  
  - Handle interactions between the web UI and the smart contracts.
  - Implement application logic such as starting a tenancy, computing total payment, and sending transactions with appropriate value/gas. 
- **User interface (HTML/CSS/JS)**  
  - Single-page web application that:
    - provides a form to add devices,
    - shows device cards with current status,
    - exposes buttons for rent / return / cancel actions, and owner approvals.  

- **Ethereum tooling**
  - **Truffle** – development framework (compile, migrate, test). 
  - **Ganache** – local Ethereum testnet for development and testing.
  - **MetaMask** – browser extension wallet for sending transactions.
  - **npm + lite-server / BrowserSync** – lightweight dev server with live reload.

---

## 📂 Project Structure

Typical structure of this repository:

- `contracts/` – Solidity contracts for rental logic and supporting libraries.
- `migrations/` – Truffle migration scripts for deploying contracts.
- `build/contracts/` – compiled contract artifacts (ABI + bytecode).
- `src/` – front-end source code (web UI and JS logic).
- `test/` – Truffle test files for contract functionality.
- `truffle-config.js` / `truffle.js` – Truffle configuration.

---

## 🚀 Getting Started (Prototype Setup)

> ⚠️ This is a research prototype implemented around 2020.  
> Some dependencies and tools may be outdated; version adjustments could be required.

Basic workflow:

```bash
# 1. Install dependencies
npm install

# 2. Compile contracts
truffle compile

# 3. Start a local blockchain (Ganache GUI or CLI)

# 4. Deploy contracts to the local network
truffle migrate

# 5. Start the dev server for the web UI
npm start    # or `npm run dev` / `lite-server` depending on package.json

```

---

## ✅ Testing & Evaluation

The dissertation includes:

- **Functionality tests** for all core requirements:

 - device registration, listing, renting, returning, cancelling,

 - payments and deposits.

- **Performance tests** (Truffle automated tests) showing contract operations
complete within fractions of a second on the test setup.

- **Cost analysis** of deployment and key transactions in terms of gas, Ether,
and approximate USD cost at the time of the study.

- **Security & privacy discussion**, including:

 - restricting sensitive operations to the correct caller accounts,

 - leveraging MetaMask signatures to ensure account ownership,

 - keeping user identities anonymous at the blockchain level.

Some non-functional requirements (e.g., robustness under heavy load, configurability for different business settings) were only partially tested due to time constraints.

## 🔭 Limitations & Future Work

Potential future improvements identified in the dissertation include:

- User registration and richer account management.

- Clear separation of owner vs. renter views and roles in the UI.

- Real-time booking support and a visual availability calendar.

- Integration with IPFS or a distributed database for storing richer item data
(e.g., images) and keeping only hashes on-chain to reduce gas/storage costs.

- Encryption/decryption support for sensitive information.

- Exploring permissioned blockchains and business models for small and medium rental companies.

## 🧑‍💻 Author

- **Ruijing Li** – Developer & author of the original MSc dissertation
*“A Block-chain Based Electronic Device Rental Application”, University of Southampton, 2020.*

This repository is published as a portfolio artifact to demonstrate:

- end-to-end system design (smart contracts + scripts + UI),

- practical experience with Ethereum tooling,

- application of blockchain to real-world rental use cases.
