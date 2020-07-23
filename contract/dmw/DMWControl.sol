pragma solidity ^0.4.25;

import "../Address.sol";

contract DMWControl {

    using OpenZeppelinUpgradesAddress for address;

    address public owner;

    address public cooAddress;

    mapping(address=>bool) oracle;

    mapping(address=>bool) approvedProxy;

    bool public openRegister = false;


    /**
	 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
	 * account.
	 */
    constructor() public {
        owner = msg.sender;
        oracle[msg.sender] = true;
        cooAddress = msg.sender;
    }


    /**
	 * @dev Throws if called by any account other than the owner.
	 */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
	 * @dev Allows the current owner to transfer control of the contract to a newOwner.
	 * @param newOwner The address to transfer ownership to.
	 */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

    modifier onlyOracle() {
        require(oracle[msg.sender],"not orcale");
        _;
    }

    function setOracleAddress(address _addr) external onlyOwner {
        require(_addr != address(0),"address is nil");
        oracle[_addr] = true;
    }

    function delOracleAddress(address _addr) external onlyOwner {

        require(_addr != address(0),"contract is nil");

        require( oracle[_addr],"contract address has invalid" );

        delete oracle[_addr];
    }


    modifier onlyProxy() {
        require(approvedProxy[msg.sender]);
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    function setCOO(address _newCOO) external onlyOwner {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }


    modifier approved() {
        require((msg.sender == cooAddress) || openRegister,"not dmw approved");
        _;
    }

    function addApprovedProxy(address _proxy) public onlyCOO {
        require(_proxy != address(0),"_proxy is zero");
        approvedProxy[_proxy] = true;
    }

    function delApprovedProxy(address _proxy) public onlyCOO {
        approvedProxy[_proxy] = false;
    }

    function open() public onlyOwner {
        openRegister = true;
    }

    function close() public onlyOwner {
        openRegister = false;
    }

}
