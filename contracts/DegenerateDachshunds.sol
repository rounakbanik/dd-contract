//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DegenerateDachshunds is Ownable, ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint public constant MAX_SUPPLY = 8888;
    uint public constant MAX_PER_MINT = 5;

    string public baseTokenURI;

    bool public saleIsActive = false;
    uint public price = 0.06 ether;

    constructor(string memory baseURI) ERC721("Degenerate Dachshunds", "DD") {
        setBaseURI(baseURI);
    }

    // Reserve a few NFTs
    function reserveNfts(uint _count, address _to) public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNft(_to);
        }
    }

    // Get total supply minted
    function totalSupply() public view returns (uint) {
        return _tokenIds.current();
    }

    // Override empty _baseURI function 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // Allow owner to set baseTokenURI
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // Set Sale state
    function setSaleState(bool _activeState) public onlyOwner {
        saleIsActive = _activeState;
    }

    // Update price
    function updatePrice(uint _newPrice) public onlyOwner {
        price = _newPrice;
    }

    // Mint NFTs
    function mintNft(uint _count) public payable {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(_count >0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(saleIsActive, "Sale is not currently active!");
        require(msg.value >= price.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNft(msg.sender);
        }
    }

    // Mint a single NFT
    function _mintSingleNft(address _to) private {
        _tokenIds.increment();
        uint newTokenID = _tokenIds.current();
        _safeMint(_to, newTokenID);
    }

    // Withdraw ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}