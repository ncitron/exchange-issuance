// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";

import { IERC20 } from "../interfaces/IERC20.sol";

contract ContractTest is DSTest {
    function setUp() public {}

    function testExample() public {
        IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        uint bal = usdc.balanceOf(0x99144f9fFC05EC5C2b98Aa306E311f40c9ca30AE);
        emit log_uint(bal);
    }
}
