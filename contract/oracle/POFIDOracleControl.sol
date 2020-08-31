pragma solidity ^0.6.8;


contract POFIDOracleControl {

    address public owner;

    mapping(address => bool) approvedUser;


    /**
	 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
	 * account.
	 */
    constructor() public {
        owner = msg.sender;
    }


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
	 * @dev Throws if called by any account other than the owner.
	 */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyApproved() {
        require(approvedUser[msg.sender]);
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


    function approve(address addr) public onlyOwner {
        approvedUser[addr] = true;
    }

    function unApproved(address addr) public onlyOwner {
        delete approvedUser[addr];
    }



}
