// File: Hello.sol
pragma solidity ^0.8.20;
//SPDX-License-Identifier: MIT 


contract HW5_2 {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    error LogError(ECPoint p, ECPoint mi, uint i);
    // event Log(uint si, uint mi);

        function matmulver(uint256[] calldata matrix,
                    uint256 n, // n x n for the matrix
                    ECPoint[] calldata s, // n elements
                    uint256[] calldata o // n elements
                ) public view returns (bool verified) {
            
            require(matrix.length == n * n, "Size parameter does not correspond to matrix length");
            require(s.length == n, "Size parameter does not correspond to vector length");
            ECPoint memory g1 = ECPoint(1, 2);
            
            ECPoint[] memory m = matmul(matrix, n, s);
            for (uint i = 0; i < n; i++) {
                ECPoint memory p = scalePoint(g1, o[i]);
                if (p.x != m[i].x || p.y != m[i].y) {
                    revert LogError(p, m[i], i);
                }
            }

            return true;
        }

        function matmul(uint256[] calldata matrix,
                    uint256 n, // n x n for the matrix
                    ECPoint[] calldata s // n elements
                ) public view returns (ECPoint[] memory mul) {
        ECPoint[] memory o = new ECPoint[](s.length);
        for (uint i = 0; i < n; i++) {
            ECPoint memory ecpoint = scalePoint(s[i], matrix[i * n]);
            // emit Log(i, i*n);
            for (uint j = 1; j < n ; j++) {    
                // get the current x coordinate from matrix
                    uint256 m_ind = i * n + j;
                    ECPoint memory scaledp = scalePoint(s[j], matrix[m_ind]);
                    ecpoint = addPoints(ecpoint, scaledp);
                    // emit Log(j, i*n);
            }
            o[i] = ecpoint;
        }
        return o;
    }

    function addPoints(ECPoint memory A, ECPoint memory B) public view returns (ECPoint memory sum) {
        bytes memory payload = abi.encode(A.x, A.y, B.x, B.y);
        (bool ok, bytes memory resp) = address(6).staticcall(payload);
        require(ok, "addPoints failed");
        (uint s_x, uint s_y )= abi.decode(resp, (uint256, uint256));
        
        return ECPoint(s_x, s_y);
    }

    function scalePoint(ECPoint memory P, uint256 s) public view returns (ECPoint memory product) {
        bytes memory payload1 = abi.encode(P.x, P.y, s);
        (bool ok, bytes memory resp) = address(7).staticcall(payload1);
        require(ok, "scaleG1 failed");
        (uint r_x, uint r_y )= abi.decode(resp, (uint256, uint256));
        return ECPoint(r_x, r_y);
    }
}