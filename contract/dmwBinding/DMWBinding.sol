pragma solidity ^0.4.25;

contract DMWBinding {

    mapping(string=>string)  binds;

    address public ownner;

    address public dmwAddress;

    constructor() public{
        ownner = msg.sender;
    }

    function setDMW(address dmw) public {
        require(msg.sender == ownner,"not approved");
        dmwAddress = dmw;
    }

    function equals(string a, string b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        for (uint i = 0; i < bytes(a).length; i ++) {
            if(bytes(a)[i] != bytes(b)[i]) {
                return false;
            }
        }
        return true;
    }

    function binding(string  backedCoin,string  mintCoin) external returns(bool){
        require(msg.sender == ownner || msg.sender == dmwAddress,"not approved");
        if (equals(binds[mintCoin],"")){
            binds[mintCoin] = backedCoin;
        }else {
            require(equals(binds[mintCoin],backedCoin),"invalid backedCoin");
        }
        return true;

    }


    function bindBackeCoin(string mintCoin) public view returns(string){
        return binds[mintCoin];
    }

}
