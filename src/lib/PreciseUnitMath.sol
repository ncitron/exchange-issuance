// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

library PreciseUnitMath {
    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b / 1 ether;
    }

    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        return (a * b - 1) / 1 ether + 1;
    }
}