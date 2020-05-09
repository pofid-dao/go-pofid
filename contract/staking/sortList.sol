pragma solidity^0.4.25;

library SortList {
    
    uint constant NULL_NODE_ID = 0;
    
    struct Node {
        uint256 next;
    }
    
    struct SortData {
        mapping(uint256 => Node) dsl;
    }
    
    function isEmpty(SortData storage self) internal view returns (bool) {
        return getStart(self) == NULL_NODE_ID;
    }
    
    function getNext(SortData storage self, uint256 _curr) internal view returns (uint256) {
        return self.dsl[_curr].next;
    }
    
    
    function getStart(SortData storage self) internal view returns (uint256) {
        return getNext(self, NULL_NODE_ID);
    }
    
    
    function insert(SortData storage self, uint256 _new) internal {
        
        require(_new != NULL_NODE_ID);
        
        uint256 _prev = 0;
        
        uint256 _cur = getStart(self);
        
        while(_new <= _cur){
            
            _prev = _cur;
            
            _cur = getNext(self,_cur);
            
        }
        
        self.dsl[_prev].next = _new;
        
        self.dsl[_new].next = _cur;
    }
    
}
