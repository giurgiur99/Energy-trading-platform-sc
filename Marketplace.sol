// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Trade.sol";


contract Marketplace {
    Trade tradeContract;

    struct Order {
        uint256 volume;
        uint256 price;
        bool orderType; // true for buy, false for sell
        uint256 timestamp;
        uint256 orderId;
        bool executed;
        address owner;
    }

    uint256 private currentOrderId = 0;
    mapping(address => uint256) public balances;
    mapping(uint256 => Order) public publicOrders;
    uint256 public totalOrders = 0;

    event OrderRegistered(address indexed prosumer, uint256 volume, uint256 price, bool orderType, uint256 timestamp);
    event OrderDeleted(uint256 orderId);
    event TradeExecuted(address indexed buyer, address indexed seller, uint256 volume, uint256 buyerPrice, uint256 sellerPrice, uint256 timestamp);
    event TradeDebug(uint256 buyerVolume, uint256 sellerVolume, uint256 buyerPrice, uint256 sellerPrice);
    event Withdrawal(address indexed user, uint256 amount);

    constructor(address _tradeContractAddress) {
        tradeContract = Trade(_tradeContractAddress);
    }

    function getOrder(uint256 orderId) public view returns (uint256, uint256, bool, uint256, address) {
        Order memory order = publicOrders[orderId];
        return (order.volume, order.price, order.orderType, order.timestamp, order.owner);
    }

    function getAllOrders() public view returns (Order[] memory) {
        Order[] memory orders = new Order[](totalOrders);
        for (uint i = 0; i < totalOrders; i++) {
            orders[i] = publicOrders[i];
        }
        return orders;
    }


    function getMyOrders() public view returns (Order[] memory) {
        uint count = 0;

        for (uint i = 0; i < totalOrders; i++) {
            if (publicOrders[i].owner == msg.sender) {
                count++;
            }
        }

        Order[] memory myOrders = new Order[](count);

        uint index = 0;
        for (uint i = 0; i < totalOrders; i++) {
            if (publicOrders[i].owner == msg.sender) {
                myOrders[index] = publicOrders[i];
                index++;
            }
        }

        return myOrders;
    }

    function registerOrder(uint256 _volume, uint256 _price, bool _orderType) public payable {
        if (_orderType == true) { // If this is a buy order
            require(msg.value >= _price, "Sent value is less than the price of the order");
            balances[msg.sender] += _price;
        }

        Order memory newOrder;
        newOrder.owner = msg.sender;
        newOrder.volume = _volume;
        newOrder.price = _price;
        newOrder.orderType = _orderType;
        newOrder.timestamp = block.timestamp;
        newOrder.orderId = currentOrderId;
        newOrder.executed = false;
        currentOrderId++;

        publicOrders[totalOrders] = newOrder;
        totalOrders++;

        emit OrderRegistered(msg.sender, _volume, _price, _orderType, block.timestamp);
    }

    function deleteOrder(uint256 orderId) public {
        Order storage order = publicOrders[orderId];

        if (order.orderType == true) { // If this is a buy order
            // Transfer the Ether locked by this order back to the owner
            payable(order.owner).transfer(order.price);

            // Deduct the Ether from the balance of the owner
            balances[order.owner] -= order.price;
        }

        delete publicOrders[orderId];

        if(totalOrders == 1) {
            totalOrders = 0;
            currentOrderId = 0;
            emit OrderDeleted(orderId);
            return;
        }
        if(totalOrders == orderId){
            totalOrders--;
            currentOrderId--;
            emit OrderDeleted(orderId);
            return;
        }
        for(uint i = orderId + 1 ; i < totalOrders ; i++) {
            publicOrders[i - 1] = publicOrders[i];
        }
        totalOrders--;
        emit OrderDeleted(orderId);
    }

    function executeTrade(uint256 volume, uint256 buyerPrice, uint256 sellerPrice, uint buyerOrderIndex, uint sellerOrderIndex) public {
        Order storage buyerOrder = publicOrders[buyerOrderIndex];
        Order storage sellerOrder = publicOrders[sellerOrderIndex];

        emit TradeDebug(buyerOrder.volume, sellerOrder.volume, buyerOrder.price, sellerOrder.price);

        require(buyerOrder.executed == false && sellerOrder.executed == false, "Order already executed");
        require(buyerOrder.volume == volume, "Buyer order volume mismatch");
        require(buyerOrder.price == buyerPrice, "Buyer order price mismatch");
        require(sellerOrder.price == sellerPrice, "Seller order price mismatch");

        address buyer = buyerOrder.owner;
        address seller = sellerOrder.owner;

        buyerOrder.executed = true;
        sellerOrder.executed = true;

        require(balances[buyer] >= buyerPrice, "Not enough Ether locked by buyer to execute trade");

        balances[buyer] -= buyerPrice;

        // Transfer Ether from the contract to the seller
        payable(seller).transfer(buyerPrice);

        tradeContract.registerTrade(volume, buyerPrice, buyer, seller);

        emit TradeExecuted(buyer, seller, volume, buyerPrice, sellerPrice, block.timestamp);
    }

    function deleteOrdersAndRefund() public {
        for (uint i = 0; i < totalOrders; i++) {
            Order storage order = publicOrders[i];

            // If the order is a buy order and not yet executed, return the locked funds
            if (order.orderType == true && order.executed == false) {
                balances[order.owner] += order.price;

                payable(order.owner).transfer(order.price);
            }
        }

        currentOrderId = 0;

        for (uint i = 0; i < totalOrders; i++) {
            delete publicOrders[i];
        }

        totalOrders = 0;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance to withdraw");

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }
}
