import "./types/ERC20.sol";
contract SampleERC20 is ERC20 {
    address public owner;
    mapping (uint=> address ) public indexToAddress;
    mapping (address => bool) public addressToBool;
    mapping (address => uint) public addressToAmount;


    struct TokenHolders{
        mapping (address => bool) tokenHolders;
    }
    uint public holders = 0;
    TokenHolders tokenHoldersStruct;

    constructor() ERC20("Sample", "SMPL", 18) {
        // uint256 amount = (100000 * 10**uint(decimals()));
        uint256 amount = 1000;
        _mint(msg.sender, amount);
        // updateReceiver(msg.sender, amount);
        // tokenHoldersStruct.tokenHolders[msg.sender] = true;
        owner = msg.sender;
        // holders++;
        // updateReceiver(msg.sender);

        indexToAddress[holders] = msg.sender;
        addressToBool[msg.sender] = true;
        holders++;
        addressToAmount[msg.sender] = amount;
    }

    function mint(address account_, uint256 amount_) external onlyOwner {
        _mint(account_, amount_);
        updateHolders(account_);
    }
    function transferFrom(address sender, address recipient, uint256 amount)public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        updateHolders(sender);
        updateHolders(recipient);
        return true;
    }

    function updateHolders(address _user) internal {
        require(_user!=address(0)&&_user!=address(this),"zero address");
        if(addressToBool[_user]==false){
            indexToAddress[holders] = _user;
            addressToBool[_user] = true;
            holders++;
        }
        addressToAmount[_user] = (balanceOf(_user));
    }

    

    modifier onlyOwner{
        require(msg.sender == owner, "Function can only be called by owner");
        _;
    }
    function getBalance(address _user) external view returns(uint256) {
        uint256 balance = balanceOf(_user);
        return balance;
    }

    function getAllHolders() external view returns (address[] memory, uint[] memory){
        address[] memory addresses = new address[](holders);
        uint[] memory amounts = new uint[](holders);
        address indexAddress;

        for(uint i = 0; i < holders; i++){
            indexAddress = indexToAddress[i];
            addresses[i] = indexAddress;
            amounts[i] = addressToAmount[indexAddress];
        }
        return(addresses, amounts);
    }
}




