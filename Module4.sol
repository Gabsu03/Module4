/*
1.Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
2.Transferring tokens: Players should be able to transfer their tokens to others.
3.Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
4.Checking token balance: Players should be able to check their token balance at any time.
5.Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

contract Degen is ERC20, Ownable {

    uint256[] internal itemIds;
    mapping(uint256 => Item) public items;
    mapping(uint256 => address) public itemBuyers;

    struct Item {
        string name;
        uint256 cost;
        address owner;
    }

    constructor(address initialOwner)
        ERC20("Degen", "DGN")
        Ownable(initialOwner)
    {
        transferOwnership(initialOwner); 
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function createItem(string memory _name, uint256 _cost) external onlyOwner {
        require(_cost > 0, "Cost must be greater than 0");

        uint256 newItemId = itemIds.length;
        items[newItemId] = Item({
            name: _name,
            cost: _cost,
            owner: msg.sender
        });
        itemIds.push(newItemId);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transferTo(address to, uint256 amount) public {
        transfer(to, amount);
    }

    function redeemItem(uint256 id) external {
        require(items[id].cost > 0, "Item does not exist");
        require(balanceOf(msg.sender) >= items[id].cost, "Insufficient balance");

        _transfer(msg.sender, address(this), items[id].cost);

        itemBuyers[id] = msg.sender; 
    }

    function showStoredItemByOwner(uint256 id) external view onlyOwner returns (string memory name, uint256 cost, address itemOwner) {
        require(items[id].cost > 0, "Item does not exist");
        Item storage item = items[id];
        return (item.name, item.cost, item.owner);
    }

    function showItemBuyer(uint256 id) external view returns (address) {
        require(itemBuyers[id] != address(0), "Item has not been bought or does not exist");
        return itemBuyers[id];
    }

    function getAllItemIds() external view returns (uint256[] memory) {
        return itemIds;
    }
}