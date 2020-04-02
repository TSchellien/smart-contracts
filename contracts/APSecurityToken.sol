pragma solidity >=0.5.0 <0.7.0;

contract RESToken {

    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    event HolderAdd(address indexed added);
    
    uint256 _totalSupply;
    mapping (address => uint256) _balances;
    mapping (address => mapping(address => uint256)) _allowed;
    
    address[] _holders;
    address _owner;
    
    constructor() public payable {
        _totalSupply = 1000;
        _holders.push(msg.sender);
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
    }
    
    /*Totall token amount at creation time
    */
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return _balances[tokenOwner];
    }
    
    /* Total withdrawl amount by appointee cannot exceed allowance.
    * Allowance remains unchanged until the holder change it.
    */
    function allowance(address tokenOwner, address appointee) public view returns(uint) {
        return _allowed[tokenOwner][appointee];
    }
 
    function transfer(address to, uint tokens) public  payable returns(bool) {
        transfereFrom(msg.sender, to , tokens);
        return true;
    }
    
    function transfereFrom(address from, address to , uint tokens) public payable returns (bool) {
        require(holderExist(from), "Debitor is not a holder.");
        require(holderExist(to), "Receiver is not a holder. Please add new account before transfering tokens to this account.");
        require(_balances[from] >= tokens, "Balance not enough.");
        if(msg.sender != from) {
            require(_allowed[from][msg.sender] >= tokens, "Not enough tokens authorized");
        }
        
        _balances[from] = _balances[from] - tokens;
        _balances[to] = _balances[to] + tokens;
        
        emit Transfer(from, to , tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool) {
        require(checkHolderPermission(msg.sender), "Account not authorized.");
        require(_balances[msg.sender] >= tokens, "Balance not enough.");
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
 //============================== Helper methods ========================================
 
 function holderExist(address accountToCheck) public view returns(bool) {
     for(uint i = 0; i<_holders.length; i++) {
         if(_holders[i] == accountToCheck) {
             return true;
         }
     }
     return false;
 }
 
 function addHolder(address accountToAdd) public returns (bool) {
     require(!holderExist(accountToAdd), "Holder already exists.");
     require(checkHolderPermission(msg.sender), "Not authorized!");
     _holders.push(accountToAdd);
     assert(holderExist(accountToAdd));
     emit HolderAdd(accountToAdd);
     return true;
 }
 
 
 function checkHolderPermission(address toCheck) public view returns (bool) {
     return (holderExist(toCheck));
 }
 function checkOwnerPermission(address toCheck) public view returns (bool) {
     return (toCheck == _owner);
 }
 function checkAppointeePermission(address toCheck, address mapToOwner) public view returns (bool) {
     return (_allowed[mapToOwner][toCheck] != 0);
 }
 function getOwner() public view returns(address) {
     return _owner;
 }
    
}
