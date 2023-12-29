# BaaS: Bridge-as-a-Service

Bridge-as-a-Service (BaaS) is a developer framework to build cross-chain bridges in a permissionless fashion. BaaS is a set of standardized contracts that form an API to leverage ElkNet's cross-chain message transport capabilities. Using BaaS, developers can build a bridge between two blockchains to implement arbitrary behavior, including bridging of tokens, cross-chain trades, data transfers, and combinations of the above.

BaaS, like ElkNet, currently only supports EVM chains. It will be available on all chains currently supported by Elk after Beta release. Eventually, we plan to support non-EVM chains as well, which this document currently does not cover.

## Practical Aspects

### Current Limitations

BaaS is currently in **Alpha 2**, which means this is experimental software that may not offer the stability or security of Beta or General Release software.

The current BaaS API is complete. However, you should expect breaking changes in the API between Alpha and Beta releases. It is likely that these changes will be minimal and target mostly the functions' signatures and naming, e.g., to add fees.

Currently, BaaS is available on the following testnets:

* Avalanche Fuji
* Polygon Mumbai
* Fantom Testnet
* Optimism Testnet
* Ethereum Ropsten

BaaS is also available on the following mainnets:

* Avalanche
* Polygon
* Binance Smart Chain
* Linea
* Q

BaaS developers and users are currently not charged any fees for using the service (Elk pays the gas costs on mainnets). Developers may use the service in production, although this is not recommended. Note that if your bridge uses significant gas, we reserve the right to rate-limit or terminate your access.

### Gaining Access to BaaS

Eventually, upon Beta and General Availability, BaaS will be permissionless, and anyone can build a bridge in exchange for staking Moose NFTs in a special contract. However, the Alpha requires no such staking, and you may simply join the [ElkDev Telegram Channel](https://t.me/ElkDev) and fill the [following form](https://forms.gle/vYHUd5CoZrbiGZut7) to get early access.

{% hint style="warning" %}
Note that this access is free of charge, and we will never charge you for it or ask you to send tokens in exchange for access! If someone contacts you asking for these things, please disregard them and report the incident to us.
{% endhint %}

### Deployment Addresses

Below are the deployment addresses of each Alpha 2 contract on the different chains.

_Currently deploying. Please check back in a day or two..._

### Alpha 2 Expiry

The present Alpha will be maintained until February 28, 2024. After that deadline, it will be terminated and replaced by another Alpha or Beta release.

### License

The BaaS codebase is distributed under a Business Source License (BUSL-1.1). This license means that the code is open source, but you cannot use, reproduce, or change it for commercial use without our permission. Approved BaaS Alpha Developers are automatically granted an unrestricted license to use the BaaS codebase until the Alpha expiration date.

## BaaS Overview

BaaS is a solidity framework designed to facilitate the development of cross-chain applications using Elk's cross-chain transport: ElkNet.

### ElkNet and Bifrost

ElkNet is a cross-chain messaging layer that executes as a distributed peer-to-peer network of nodes implementing a messaging abstraction: _cross-chain atomic transaction_. A cross-chain atomic transaction spans multiple independent blockchains, each executing a series of local operations that either succeed (commit) or fail (abort). The current implementation of ElkNet supports two-way ordered transactions that each execute atomically on their chain within a local transaction. As the blockchains involved typically do not communicate directly, we implement the all-or-nothing property of cross-chain transactions using compensating transactions in case of a failure, ensuring atomicity across the blockchains. ElkNet nodes collectively provide that property.

ElkNet is an off-chain entity that communicates with on-chain smart contracts. The `Bifrost` contract is a low-level contract that enables direct interaction with the ElkNet. The Bifrost API is a low-level interface of the ElkNet, i.e., a thin wrapper around its messaging abstraction. Think of it as the "system call interface" to an operating system kernel rather than a fully-fledged higher-level library (e.g., libc). Most application developers will want to implement bridges using the higher-level SDK.

### BaaS SDK

Each bridge implemented using BaaS consists of three broad parts, which must exist on every supported chain (with possibly different implementations).

* `Realm`: A cross-chain application that exists on multiple chains. Realm refers to a unique identifier for that application and the on-chain implementation of the bridging logic.
* `BaasConfig`: A configuration contract that lives on each chain and provides information to connect the realm across blockchains.
* Entry point (optional): A smart contract that provides a custom entry point for bridge users. Elk provides a default low-level entry point called `Bifrost,` which can serve as a shared entry point if application developers do not wish to provide a custom contract.

In addition to the above three parts, bridges involving token transfers (whether ERC20, ERC721, or others) may use the `IReservoir` interface and base contracts that facilitate the implementation of token bridging for BaaS applications.

### XTransfer

Every cross-chain message in ElkNet is represented by an [`XTransfer`](https://github.com/elkfinance/baas/blob/main/contracts/helpers/XTransfer.sol), which is a struct that simply contains a source chain, a destination chain, and some encoded data. XTransfers are essentially transport _packets_ for ElkNet. Every BaaS application is materialized around a set of XTransfer messages that the different smart contracts in the BaaS SDK interact with to implement the bridging logic.

From the perspective of the source chain sending an XTransfer message, the message has one of four possible status values: Unknown, Initiated (sent), Completed (received successfully, i.e., commit), and Aborted (failure, i.e., abort).

## Getting Started

### Prerequisites

* Your favorite web3 wallet installed and configured on each blockchain (mainnet or testnet) you are interested in (e.g., using https://chainlist.org)
* Funded wallet(s) for deploying smart contracts and testing (no need for ELK tokens in Alpha)
* Whitelisted wallet with your own realm(s) with ElkNet BaaS (contact us for access)
* A development environment configured to work with each blockchain

### Github BaaS Repository

You may find the BaaS repository [here](https://github.com/elkfinance/baas). Note that this is a public repository that only corresponds to the current Alpha, not the ongoing Beta development. Once in Beta, we will make it easy for developers to integrate BaaS contracts into their code with a simple import.

### Implementing a Realm

The `IRealm` interface can be found [here](https://github.com/elkfinance/baas/blob/main/contracts/interfaces/IRealm.sol). Realms implement the core logic of your cross-chain application. As such, they must be carefully implemented and thoroughly tested.

Below is a description of the different realm functions.

* **`enabled`**: Allows users and the BaaS SDK to determine if a realm's functionality is currently accessible on the current chain. Developers may opt to implement ways to disable a realm by calling a separate function on the realm or even to enable it arbitrarily based on the contract's state.
* **`targetChainSupported(uint32 chain)`**: Verifies if the realm supports cross-chain transactions to a specified target chain, identified by a chain identifier (e.g., '1' for Ethereum).
* **`uniqueId()`**: Generates and returns a unique identifier to reference transactions within the realm. Developers may opt to implement custom encodings for transaction identifiers as per their application's semantics.
* **`exiting(bytes32 id, XTransfer calldata xt)`**: Callback invoked during a cross-chain transaction exiting on the target chain. The callback may used to modify the XTransfer message, update the internal state of the contract, or make calls to another contract.
* **`entering(bytes32 id, XTransfer calldata xt)`**: Callback triggered during a cross-chain transaction entering from the source chain. The callback may used to modify the XTransfer message, update the internal state of the contract, or make calls to another contract.
* **`completed(bytes32 id, XTransfer calldata xt)`**: Handles the completion of a cross-chain transfer on the source chain, using an identifier and the transfer data for record-keeping or finalization steps.
* **`aborted(bytes32 id, XTransfer calldata xt, string calldata message)`**: Deals with failed cross-chain transfers on the source chain, providing an identifier, the transfer data, and a failure message for appropriate error handling or rollback actions.

### Configuring the Realm with `BaasConfig`

The `BaasConfig` contract can be found [here](https://github.com/elkfinance/baas/blob/main/contracts/BaasConfig.sol). There is one configuration contract per chain, which is used by all BaaS realms. As the Alpha BaaS does not currently use Moose NFTs, all realms are currently granted by the contract's administrator (Elk). Make sure to request a realm identifier (if not already done) before moving to the next stage.

`BaasConfig` currently supports a single function for realm owners, `setRealm,` which allows them to configure the address of their `Realm` contract, allowing to ElkNet and supporting contracts to materialize the cross-chain realm abstraction for that particular realm.

### Writing an entry point

To facilitate using your bridge or cross-chain application, we recommend you implement a custom contract that acts as an entry point for users. Typically, that custom contract will contain one or more functions that create an `XTransfer` message and send it through the bridge with the corresponding realm information. Below is a simple example:

```
  import "IBifrost.sol";

  contract EntryPoint {

    uint256 public constant REALM_ID = 42;

    IBifrost public immutable bifrost;

    event TransferSent(bytes32 id, uint256 dstChain, address sender, address receiver, address token, uint256 amount, bytes32 message);

    constructor(address _bifrost /*, ... */) {
        bifrost = IBifrost(_bifrost);
        /* ... */
    }

    function transfer(uint256 _dstChain, address _receiver, address _token, uint256 _amount, bytes32 _message) external {
        bytes memory data = abi.encode(msg.sender, _receiver, _amount, _message);
        bytes32 id = bifrost.xTransfer(REALM_ID, _dstChain, data);
        emit TransferSent(id, _dstChain, msg.sender, _receiver, _token, _amount, _message);
    }
  }
```

You may, of course, decide not to provide an entry point. In this case, users must write their own XTransfer and send it through the Bifrost to interact with your realm.

### Working with Reservoirs

A realm can have a reservoir on each supported chain to manage the transfer of tokens to/from user wallets. The `IReservoir` interface abstracts the details of managing the tokens themselves, allowing the developer to focus on writing applications and bridging logic.

#### Reservoir Implementation

Each reservoir must implement the [`IReservoir` interface](https://github.com/elkfinance/baas/blob/main/contracts/interfaces/IReservoir.sol), which contains seven functions that are specific to a chain. Developers may use the same interface implementation on all chains in a realm, but they may also opt for different implementations on different chains. Similarly, a single reservoir interface can be used by multiple realms. All reservoirs in a realm are bound together by the ElkNet and operate in unison to provide the desired cross-chain functionality.

The two main functions of a reservoir are `deposit` and `withdraw.` As their name indicates, these functions are used by ElkNet to deposit tokens on the source chain and withdraw tokens on the target chain. Each deposit/withdrawal operation is associated with an identifier (id). ElkNet ensures that each pair of deposit/withdrawal is called exactly once and in the (global) order deposit -> withdrawal. Developers may implement the `deposited` and `withdrawn` functions to allow on-chain querying of the associated operation. Note that the two latter functions are not called by the core ElkNet, and their implementation is optional.

Each reservoir is also associated with a `tokenAddress` function that returns the token contract address on the chain where the reservoir is deployed. A reservoir may connect different token addresses on different chains. The `available` function lets the ElkNet and 3rd party users query the number of tokens in the reservoir. That function must be implemented correctly, as it is used internally by ElkNet for security audits and funds monitoring.

Finally, to prevent "reservoir hijacking," each reservoir must implement a `validateRealm` function that returns true if and only if the reservoir is valid for the associated realm identifier.

#### Reservoir Behavior

Due to their generic nature, reservoirs can be used to implement arbitrary behaviors for cross-chain transfers. Below are some possible examples. You may find some example implementations in our BaaS Github repository.

* **Lock/release**: upon cross-chain transfer, the token is locked on the source chain (via `deposit`) and released on the target chain (via `withdraw`). This use case should be popular with projects launching their token on multiple chains.
* **Lock/release with fixed, global supply**: similar to lock/release but with a fixed, global supply. In this case, reservoirs on each chain would usually mirror each other and contain all available tokens on each chain, creating the illusion of a token that is effectively native to each chain. This is the use case chosen for the ELK token.
* **Burn/mint**: upon cross-chain transfer, the token is burned on the source chain (via `deposit`) and minted on the target chain (via `withdraw`). This is an alternative approach for projects with their token on multiple chains if the token supports burning and minting.
* **Lock/mint** (aka **wrap**): upon cross-chain transfer, the token is locked on the source chain (via `deposit`), and a synthetic token is minted on the target chain (via `withdraw`). This use case usually corresponds to an application that wants to proxy a token to a different chain, for example, stablecoin bridging.

Many other use cases are possible. For example, a developer could opt for a hybrid approach where the default behavior is lock/release until there is no exit liquidity, after which the reservoir could mint an IOU token or similar. Similarly, a token could be locked on one chain, and a completely different token (e.g., a different symbol, amount, or token type) would be released/minted on the target chain.

You could actually mint an NFT that represents a given amount of token on the source chain in a cross-chain transfer (and have that NFT redeemable on the source chain later on)! You could bridge a token into the token of another bridge, thereby reducing fragmentation. You could imagine scenarios where funds are withdrawn after some time or after manual validation. The sky's the limit!

### Working with the `Bifrost` contract

The Bifrost contract is the low-level interface to the ElkNet. As such, it can both send and receive messages from the `ElkNet` interface contract, which is directly under the control of the ElkNet peer-to-peer network. The `ElkNet` interface contract is currently not public and is subject to change. However, the `Bifrost` contract's ABI is somewhat set in stone, although it may change slightly between Alpha and Beta.

Users may only interact with the Bifrost by calling the non-permissioned functions `xTransferIn` (or `xTransfer`, which offers some syntactic sugar) and `xTransferStatus`. `xTransferIn` lets the user pass an XTransfer to the associated realm, triggering a cross-chain transaction involving that realm. `xTransferStatus` enables the user to query for the status of a given transfer, which can be one of Unknown, Initiated, Completed, or Aborted, as described above. Note that you may only query the transfer status of a transfer sent from the chain you are querying the Bifrost on.

## Advanced Topics

This section lists some advanced topics and recipes that may be useful for developers.

### ERC20Realm

The `ERC20Realm` contract is an abstract contract that makes it easy for developers to implement a realm whose purpose is bridging ERC20 tokens. The contract contains a variety of hooks to customize the bridging behavior, allowing, e.g., whitelisting, custom fees, reflection token bridging, etc.

The `ERC20Realm` contract can be found [here](https://github.com/elkfinance/baas/blob/main/contracts/libraries/ERC20Realm.sol).

### BaaS + FaaS = StakingReservoir

The StakingReservoir is a reservoir that doubles as a staking pool (or farm). This contract allows developers to build cross-chain applications at the intersection of two of Elk's flagship products and leverage the flexibility of our SDK. Below are some use cases for StakingReservoir:

* Exit liquidity pool for a custom bridge that rewards liquidity providers with combined APRs from bridging fees and reward tokens.
* Cross-chain farm that lets users farm tokens on a different chain than their current chain transparently.
* Cross-chain payments (see Xion Global for an example).
* And more, as yet undiscovered and awaiting creation, ideas...

_A StakingReservoir example contract will be provided soon._

### Paranodes

Paranodes are, in our experience, an often misunderstood concept. These are not ElkNet nodes, nor are they necessarily distributed nodes. A paranode aims to provide external information into the ElkNet or perform information that cannot be done on-chain. For security reasons, ElkNet is not allowed (or even supposed to) make calls to external services such as web2 APIs. However, in many applications, especially when building hybrid web2/3 or integrating with third-party services (e.g., aggregator API or subgraphs), there is a need for off-chain actions to be taken on behalf of a realm. In our BaaS SDK, these actions are intended to be taken by dedicated paranodes. Running a paranode requires staking a Moose on the chain where that paranode will be interfacing with a realm.

The paranode API is currently unavailable as part of this Alpha 2. We are currently testing paranodes internally for two use cases: payments (with Xion Global) and cross-chain swaps. We aim to include more information about paranodes here as soon as possible.

## FAQ

* **Why Alpha 2? What was Alpha 1?**&#x20;

Elk's BaaS is currently in Alpha 2. Alpha 1 was the first version of BaaS, which only supported ERC20 token transfers. Alpha 2 is the complete BaaS as intended and supports arbitrary data transfers across blockchains (aka universal bridge).

* **What is the difference between Alpha and Beta?**

Beta has a frozen API. If you are currently building with Alpha, expect changes! Most changes will not be significant, but notably, the main functions will include additional parameters for fees and timeouts.

* **Why should I use Elk's BaaS and not \[insert cross-chain project name]?**

Your choice! Elk is not in the business of telling people what to do.

* **I like BaaS but do not want to use ElkNet. How?**

Elk has committed to building compatible cross-chain solutions and avoiding lock-in. Therefore, you can use a different cross-chain transport if you wish. Our contracts are designed to permit that. We may include the integration of other transport protocols in our roadmap, but this is not a priority.

* **How do I get a realm? Is this what the Moose is for?**

Yes, the Moose unlocks a realm for its holder. However, the current Alpha does not integrate the Moose. Instead, you will have to contact us to get a realm (completely free of charge during Alpha).

* **Where does the Moose come in?**

Each Moose unlocks one side of the bridge on one chain. The Moose must be staked to provide that functionality, but it acts as a permissionless "license key" to build your own bridge!

* **I am a Moose holder but not a developer and do not want to build a bridge.**

No problem. You can either sell your Moose to a developer or stake it on their behalf (i.e., to unlock their bridge) and earn a share of the fees for the bridging route in question.

* **I don't have a Moose but want to build a bridge.**

No problem. You can buy a Moose on NFT marketplaces or rent a temporary Moose with Elk tokens.

* **Wen Beta? Wen GA? Wen X?**

We cannot confirm this at the moment. We are refining our roadmap and incorporating tentative deadlines for these different releases. However, as you may be aware, we can never guarantee that we will meet a deadline, and we fully acknowledge that we have been overly ambitious with deadlines in the past.

Note also that many Elk developers are not full-time, and it takes a significant effort to release such a large project, which is why it takes place in stages. In short, we will do our best, and we definitely want many people to be able to use BaaS in 2024.

* **When will Alpha 2 be available?**

We are now (end of Q4, 2023) opening up Alpha 2 to more developers. The Alpha 2 started at the end of Q1, 2023, with a single developer and has grown a bit since, but we would like to get more eyes on it now to help us squash the last few bugs.

* **How safe is BaaS?**

We would say reasonably safe, but as I am sure you understand, we cannot make any promises. Please do not use BaaS for production applications with large sums of money. Note that any BaaS application must still be checked for security end-to-end as developers may introduce flaws in their contracts (in addition to any possible weaknesses in the BaaS contracts and the transport).

* **Is there a risk that a malicious developer could implement a malicious bridge using BaaS?**

Yes, this is a definite possibility due to the flexibility and permissionless nature of BaaS. Similarly, ElkNet is a transport layer and does not (and cannot!) distinguish between honest and malicious messages. Developers must take responsibility for getting code audited and deploying bridge interfaces so that they cannot be spoofed or hijacked to harm unsuspecting users.

* **What security features should I use when building on BaaS?**

We recommend using our rate-limiting and maximum transfer amount features for any use on mainnet. Do not allow transferring large amounts and consider implementing manual confirmations when real funds are involved.

* **Is there an audit of the code?**

Not at this point since we are still undergoing significant development and breaking changes, but we plan to get this milestone completed in the future.

* **What is the difference between FaaS and BaaS?**

FaaS is our permissionless Farms-as-a-Service. At first glance, it does not have much to do with BaaS. However, the two solutions can build powerful and highly profitable bridging solutions. Specifically, you can combine FaaS and BaaS to get Reservoirs that reward liquidity providers with an APR and many tokens, much like a staking contract.

## Support

Please reach out to us on our [Developer Support Telegram channel](https://t.me/ElkDev).
