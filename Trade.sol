//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Trade {
    struct TradeDetails {
        uint256 volume;
        uint256 price;
        address buyer;
        address seller;
        uint256 timestamp;
        uint256 tradeId;
    }

    uint256 private currentTradeId = 0;

    TradeDetails[] public trades;

    event TradeExecuted(uint256 tradeId, uint256 volume, uint256 price, address buyer, address seller, uint256 currentTradeId, uint256 timestamp);

    function registerTrade(uint256 _volume, uint256 _price, address _buyer, address _seller) public {
        TradeDetails memory newTrade;
        newTrade.volume = _volume;
        newTrade.price = _price;
        newTrade.buyer = _buyer;
        newTrade.seller = _seller;
        newTrade.timestamp = block.timestamp;
        newTrade.tradeId = currentTradeId;

        trades.push(newTrade);
        emit TradeExecuted(trades.length - 1, _volume, _price, _buyer, _seller, currentTradeId, block.timestamp);
        currentTradeId++;

    }

    function getAllTrades() public view returns (TradeDetails[] memory){
        return trades;
    }

    function getMyTrades(address _address) public view returns (TradeDetails[] memory){
        uint count = 0;

        // Count the trades of the specific address
        for (uint i = 0; i < trades.length; i++) {
            if (trades[i].buyer == _address || trades[i].seller == _address) {
                count++;
            }
        }

        TradeDetails[] memory filteredTrades = new TradeDetails[](count);

        // Add the trades of the specific address to the array
        uint index = 0;
        for (uint i = 0; i < trades.length; i++) {
            if (trades[i].buyer == _address || trades[i].seller == _address) {
                filteredTrades[index] = trades[i];
                index++;
            }
        }

        return filteredTrades;
    }
}
