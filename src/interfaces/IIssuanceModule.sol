// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { ISetToken } from "./ISetToken.sol";

interface IIssuanceModule {
    function issue(
        ISetToken _setToken,
        uint _quantity,
        address _to
    ) external;

    function redeem(
        ISetToken _setToken,
        uint _quantity,
        address _to
    ) external;
}