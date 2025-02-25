// File: Hello.sol
pragma solidity ^0.8.20;
//SPDX-License-Identifier: MIT 

contract HW5 {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public view returns (bool verified) {
        
        uint p = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        uint den_inv = modExp(den, p - 2, p);
        uint r = mulmod(num, den_inv, p);
        
        ECPoint memory pr = scaleG1(r);
        
        ECPoint memory ps = addPoints(A, B);

        verified = (pr.x == ps.x && pr.y == ps.y);

        return verified;
        
    }

    function addPoints(ECPoint calldata A, ECPoint calldata B) public view returns (ECPoint memory sum) {
        bytes memory payload = abi.encode(A.x, A.y, B.x, B.y);
        (bool ok, bytes memory resp) = address(6).staticcall(payload);
        require(ok, "addPoints failed");
        (uint s_x, uint s_y )= abi.decode(resp, (uint256, uint256));
        
        return ECPoint(s_x, s_y);
    }

    function scaleG1(uint256 s) public view returns (ECPoint memory product) {
        bytes memory payload1 = abi.encode(1, 2, s);
        (bool ok, bytes memory resp) = address(7).staticcall(payload1);
        require(ok, "scaleG1 failed");
        (uint r_x, uint r_y )= abi.decode(resp, (uint256, uint256));
        return ECPoint(r_x, r_y);
    }

    function modExp(uint256 base, uint256 exp, uint256 mod) 
		public
		view
		returns (uint256) {
		
		bytes memory precompileData = abi.encode(32, 32, 32, base, exp, mod);
        (bool ok, bytes memory data) = address(5).staticcall(precompileData);
        require(ok, "expMod failed");
        uint ret = abi.decode(data, (uint256));
        return ret;
    }       

}