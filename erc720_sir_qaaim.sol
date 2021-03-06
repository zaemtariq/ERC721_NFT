pragma solidity ^0.6.0;

import "./IERC721.sol";
import "./ERC165.sol";
import "./SafeMath.sol";


/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is ERC165, IERC721{
    using SafeMath for uint256;

    uint _totalSupply; //last token id;.. 
    
    // Mapping from owner address to their set of owned tokens
    mapping (address => uint256[]) private _ownerTokens;
    //qasim ->1,2,3,4
    //        0,1,2,3 
    //Noman -> 5,6
    //         0,1
    //Ahmed -> 7,8,9
    //         0,1,2
    //Aiman -> totalSupply+1 => 10
    //                          0
    
    
    //mapping for holding index of token in owner 
    mapping(address => mapping(uint256 => uint256)) private _ownerTokenIndex;
    //qasim -> 1 => 0, 2=>1, 3=>2, 4=>3 
    //Noman -> 5 => 0, 6=>1
    

    // token mapping from token ids to their owners
    mapping(uint256 => address) private _tokenOwners;
    //1 -> qasim
    //2 -> qasim
    //3 -> qasim
    //4 -> qasim
    //5 -> Noman
    //6 -> Noman
    

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;
    //1 -> mudassir
    //4 -> mudassir
    //5 -> Aiman
    //6 -> Ahmed
    
    /**
    * For a given account, for a given operator, store whether that operator is
    * allowed to transfer and modify assets on behalf of them.
    */
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    //qasim -> mudassir = true
    //Noman -> Aiman = true
    
    
    //
    
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    
    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        
        return _ownerTokens[owner].length;
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _tokenOwners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }
    
    /**
     * @dev Gets index of particular token from Owner's collection
     * @param tokenId uint256 ID of the token to query the index of
     * @param owner address 
     * @return uint256 index of token
     */
    function indexOf(address owner, uint256 tokenId) public view returns (uint256){
        require(tokenId > 0,"ERC721: Query for non existent token");
        require(owner != address(0), "ERC721: owner query for nonexistent token");
                               // 0 =  Noman   5 
        return _ownerTokenIndex[owner][tokenId];
    }
    
    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        return _ownerTokens[owner][index];
    }


    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() public view  returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() public view  returns (string memory) {
        return _symbol;
    }

   
   

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view  returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _totalSupply;
    }


    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param operator operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */                               //qasim        //mudassir
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * 
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transfer(address to, uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        address from = msg.sender;
        _transfer(from, to, tokenId);
    }
    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    

  
    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        require(tokenId > 0,"ERC721: Token does not exist");
        address owner = _tokenOwners[tokenId];
        
        if(owner != address(0))
            return true;
        else
            return false;
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }



    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        //require(!_exists(tokenId), "ERC721: token already minted");

        _totalSupply = _totalSupply.add(1);
        
        //state update on adding token
        _addToken(to,tokenId);
        
        emit Transfer(address(0), to, tokenId);
    }
    
    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     *                       4
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        //       qasim

        // Clear approvals
        _approve(address(0), tokenId);
                  0           4    
        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
        _totalSupply = _totalSupply.sub(1);
        
        //state update on token delete
        _deleteToken(owner,tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(tokenId > 0, "ERC721: Invalid tokenId - tokenId can't be 0");
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

       

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        //delete of from address;
        _deleteToken(from,tokenId);
        
        //adding new token
        _addToken(to,tokenId);
        
        emit Transfer(from, to, tokenId);
    }

 /*
    * @dev Internal function to adding token safely.
    * 
    * Requires token shouldn't already exist;
    * Requires token shouldn't owned by owner
    * @param address of owner to assign a token
    * @param tokenId which requires to add
    */
    function _addToken(address owner, uint tokenId) internal virtual returns(bool success, uint256 newIndex){
        //token shouldn't be exist;
        require(!_exists(tokenId),"ERC721: Token already exist");
        require(_tokenOwners[tokenId] != owner,"ERC721: Owner already owned token");
        
        //assign owner to token
        _tokenOwners[tokenId] =  owner;
        
        //push new token into owner's posession
        _ownerTokens[owner].push(tokenId);
        
        //stored new index 
        newIndex = _ownerTokens[owner].length-1;
        _ownerTokenIndex[owner][tokenId]= newIndex;
        
        success = true;
    }

    /*
    * @dev Internal function to delete token safely.
    * Token shouldn't already exist;
    * Token shouldn't owned by owner

    * @param address of owner, owns a token
    * @param tokenId to be deleted
    */                            qasim        3
    function _deleteToken(address owner, uint tokenId) internal virtual returns(bool success, uint256 index){
        require(_exists(tokenId),"ERC721:Invalid Token - Token not exist");
        require(_tokenOwners[tokenId] == owner,"ERC721: Invalid ownership - Token is not owned by owner");
        //2                       qasim   3
        index = _ownerTokenIndex[owner][tokenId];
        
        //more than one token swap last entry to current index
        //                      4
        //qasim  1,2,3,4
        //index  0,1,2,3
        
        if(_ownerTokens[owner].length>1){
            // 4                           qasim               qasim   4 -1 =3
            uint lastToken = _ownerTokens[owner][_ownerTokens[owner].length-1];  
            //           qasim  2         4
            _ownerTokens[owner][index] = lastToken;
            //               qasim   4             2
            _ownerTokenIndex[owner][lastToken] = index;
        }
        //qasim  1,2,4,4
        
        //remove last entry
        _ownerTokens[owner].pop();
        //qasim  1,2,4
        //remove Index
        delete _ownerTokenIndex[owner][tokenId];
        //remove owner
        delete _tokenOwners[tokenId];
        success = true;
    }
   
    /**
     * @dev Internal function to set the token URI for a given token.
     *
     * Reverts if the token ID does not exist.
     *
     * TIP: If all token IDs share a prefix (for example, if your URIs look like
     * `https://api.myproject.com/token/<id>`), use {_setBaseURI} to store
     * it and save gas.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }


 
    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    
    
    /** starting point **/
    uint256 public tokenIdCounter;
    function registerProperty(string memory plotno) public {
        
        tokenIdCounter = tokenIdCounter.add(1);
        _mint(msg.sender,tokenIdCounter);
        _setTokenURI(tokenIdCounter,plotno);
    }
}
