// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {NFT_Single} from "./NFT721.sol";
import {NFT_Multiple} from "./NFT1155.sol";

contract Marketplace {
    address payable public marketplace_owner;
    uint256 public marketplace_nft_listing_price = 0.002 ether;
    uint256 public marketplace_collection_listing_price = 0.05 ether;
    uint256 public collection_count;

    constructor() {
        marketplace_owner = payable(msg.sender);
    }

    struct CollectionParams {
        string name;
        string symbol;
        string description;
        string image_url;
        string collection_url;
        string contract_type;
    }

    struct Collection {
        uint256 id;
        string name;
        string symbol;
        string description;
        string image_url;
        string collection_url;
        string contract_type;
        address creator;
        address contract_address;
    }

    mapping(uint256 => Collection) public collections;
    mapping(address => uint256) public floor_prices;
    mapping(address => uint256) public volume;
    mapping(address => uint256) public item_count;
    mapping(address => uint256) public owner_count;

    function create_collection(
        CollectionParams memory params
    ) public payable returns (bool success) {
        require(
            campare_collection(params.contract_type, "ERC721") ||
                campare_collection(params.contract_type, "ERC1155"),
            "Invalid contract type!"
        );

        require(
            msg.value >= marketplace_collection_listing_price,
            "Insufficient funds for listing collection"
        );
        collection_count++;

        if (campare_collection(params.contract_type, "ERC721")) {
            bytes memory erc_721_bytecode = abi.encodePacked(
                type(NFT_Single).creationCode,
                abi.encode(msg.sender, params.name, params.symbol)
            );

            address contract_addr;

            assembly {
                contract_addr := create(
                    0,
                    add(erc_721_bytecode, 0x20),
                    mload(erc_721_bytecode)
                )
            }

            require(
                contract_addr != address(0),
                "NFT_Single contract creation failed!"
            );
        } else if (campare_collection(params.contract_type, "ERC1155")) {}

        return true;
    }

    function campare_collection(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
