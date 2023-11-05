# Energy Trading Platform Smart Contracts

## Overview

This repository contains a collection of Ethereum smart contracts for an energy trading platform that allows users to register buy and sell orders for energy, execute trades, and issue trade certificates. The smart contracts are built with Solidity and use the OpenZeppelin library for secure contract development.

### Contracts

- `Marketplace`: Manages the creation and deletion of buy and sell orders, keeps track of user balances, and handles the execution of trades.
- `Trade`: Keeps a record of all completed trades and provides functions to access trade details.
- `TradeCertificate`: A simple ERC721 contract that mints trade certificates representing completed energy trades.

## Features

- **Order Management**: Users can create and delete energy orders, specifying the volume and price, and whether it's a buy or sell order.
- **Trade Execution**: The marketplace contract facilitates the execution of trades when a matching buy and sell order is found.
- **Trade History**: All executed trades are stored and can be retrieved, including filtering by user address.
- **Trade Certificates**: Upon successful trade execution, a trade certificate can be minted as an ERC721 token.

## Events

- `OrderRegistered`: Fired when a new order is registered in the marketplace.
- `OrderDeleted`: Emitted when an order is deleted.
- `TradeExecuted`: Dispatched when a trade is executed successfully.
- `TradeDebug`: Debug event for trade execution details (should be removed for production).
- `Withdrawal`: Occurs when a user withdraws funds from their balance.

## Usage

To interact with the smart contracts, deploy them to an Ethereum network and then call their functions using a web3 library or through a frontend interface connected to Metamask or another Ethereum wallet.

### Contract Deployment

Deploy contracts using a migration script with your preferred development framework, like Hardhat or Truffle.

### Interacting with Contracts

Call contract functions directly using a web3 provider, or integrate them into a frontend application.

## Security

The contracts use OpenZeppelin's Ownable contract for ownership management, ensuring that only authorized users can perform critical actions.

---
Disclaimer: This is a prototype contract system. Please ensure thorough auditing before using in a production environment.
