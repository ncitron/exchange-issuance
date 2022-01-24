// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { ISetToken } from "./ISetToken.sol";

interface IIssuanceModule {
    function issue(
        ISetToken _setToken,
        uint256 _quantity,
        address _to
    ) external;
}