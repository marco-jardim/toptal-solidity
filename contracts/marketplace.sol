// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping (uint256 => uint256) private _prices;
    mapping (uint256 => address) private _stakes;
    mapping (uint256 => mapping (address => uint256)) private _stakeOwners;
    mapping (uint256 => uint256) private _totalStaked;
    mapping (address => uint256) private _etherBalance;

    event Mint(address indexed to, uint256 indexed tokenId);
    event Burn(uint256 indexed tokenId);
    event Stake(address indexed owner, uint256 indexed tokenId);
    event PriceChange(uint256 indexed tokenId, uint256 newPrice);
    event EtherBalanceChange(address indexed owner, uint256 newBalance);
    event StakeBalanceChange(address indexed owner, uint256 newBalance);
    event TotalStakedChange(uint256 tokenId, uint256 newTotalStaked);
    event EtherSent(address indexed to, uint256 value);

    constructor() ERC721("NFT Marketplace", "NFTM") {}

    // Overrides baseURI for custom metadata functionality
    function _baseURI() internal pure override returns (string memory) {
        return "https://www.toptal.com/";
    }

    // Internal function that sets new price for a token
    // @dev: This function is not part of the standard ERC721 interface
    function _setPrice(uint256 tokenId, uint256 price) internal {
        _prices[tokenId] = price;
        emit PriceChange(tokenId, price);
    }

    // Standard ERC721 safeMint function
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);        
    }

    // Public minting function
    // @dev: This function is not part of the standard ERC721 interface
    // receives a URI and a price for the NFT
    function publicMint(string memory uri, uint256 price) public {
       uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri); 
        _setPrice(tokenId, price);
        _totalStaked[tokenId] = 0;
        emit Mint(msg.sender, tokenId);
    }

    // Internal function that sets a staker for a given tokenId
    // @dev: This function is not part of the standard ERC721 interface
    function _setStake(uint256 tokenId, address staker) internal {
        _stakes[tokenId] = staker;
    }

    fallback() external payable {
        // do nothing
    }

    // Standard receive function that increases the balance of the sender
    receive() external payable {
        _etherBalance[address(msg.sender)] += msg.value;
        emit EtherBalanceChange(msg.sender, _etherBalance[msg.sender]);
    }

    // Function that returns the internal contract ether balance of an address
    // @dev: This function is not part of the standard ERC721 interface
    function getEtherBalance(address user) public view returns (uint256) {
        return _etherBalance[user];
    }

    // Function that stakes a tokenId for a given staker (msg.sender)
    // Note: The staker must send the staking fee to the contract before calling this function
    // @dev: This function is not part of the standard ERC721 interface
    function stake(uint256 tokenId, uint256 amount) public {
        require(_totalStaked[tokenId] < _prices[tokenId], "Sorry, this token is already staked");
        require(_prices[tokenId] >= _totalStaked[tokenId] + amount, "Sorry, you can't stake more than the price.");
        require(amount <= _etherBalance[msg.sender], "Sorry, you don't have enough ether to stake."); 
            
        address seller = ownerOf(tokenId);
        bool sent = _sendEther(payable(seller), amount);

        require(sent, "Failed to send Ether");
        emit EtherSent(seller, amount);

        _etherBalance[msg.sender] -= amount;
        _setStake(tokenId, msg.sender);
        _totalStaked[tokenId] += amount;
        _stakeOwners[tokenId][msg.sender] += amount;

        emit Stake(msg.sender, tokenId);
        emit StakeBalanceChange(msg.sender, _etherBalance[msg.sender]);
        emit TotalStakedChange(tokenId, _totalStaked[tokenId]);
    }

    // Internal function that sends ether to a given address
    // @dev: This function is not part of the standard ERC721 interface
    function _sendEther(address payable _to, uint256 amount) internal returns (bool) {
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        return sent;
    }

    // Internal function that returns the price of a given tokenId
    // @dev: This function is not part of the standard ERC721 interface
    function getPrices(uint256 tokenId) public view returns (uint256) {
        return _prices[tokenId];
    }

    // Function that returns the total staked of a given tokenId
    // @dev: This function is not part of the standard ERC721 interface
    function getTotalStaked(uint256 tokenId) public view returns (uint256) {
        return _totalStaked[tokenId];
    }

    // Function that returns the total staked of a given tokenId for a given staker
    // @dev: This function is not part of the standard ERC721 interface
    function getStakeOwners(uint256 tokenId, address owner) public view returns (uint256) {
        return _stakeOwners[tokenId][owner];
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        emit Burn(tokenId);
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
