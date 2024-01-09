// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./common/ERC2981.sol";

contract NFTCon is Context,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721URIStorage,
    ERC2981,
    AccessControl
    {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private baseTokenURI;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    address public owner;
    mapping(uint256 => bool) private usedNonce;

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor(string memory name, string memory symbol, 
        string memory _baseTokenURI)
        ERC721(name, symbol) {

        baseTokenURI = _baseTokenURI;
        owner = _msgSender();
        _tokenIdTracker.increment();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

    } 
    function transferOwnership(address newOwner)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
        {
            require(
                newOwner != address(0),
                "Ownable: new owner is the zero address"
            );
            _revokeRole(DEFAULT_ADMIN_ROLE, owner);
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
            return true;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address user, Sign calldata sign) public onlyRole(MINTER_ROLE) returns (uint256) {
        require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
        usedNonce[sign.nonce] = true;
        verifySign(_tokenURI, msg.sender, sign);
        _tokenId = _tokenIdTracker.current();        
        _safeMint(user, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        _setTokenRoyalty(_tokenId, _msgSender(), _royaltyFee);
        _tokenIdTracker.increment();
        return _tokenId;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory _baseTokenURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseTokenURI = _baseTokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTokenURI(tokenId, _tokenURI);
    }

    // The following functions are overrides required by Solidity.

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
    
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
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
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}