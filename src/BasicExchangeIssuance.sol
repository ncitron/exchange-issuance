// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ExchangeHelpers } from "./lib/ExchangeHelpers.sol";
import { IIssuanceModule } from "./interfaces/IIssuanceModule.sol";
import { ISetToken } from "./interfaces/ISetToken.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { SetLib } from "./lib/SetLib.sol";

contract BasicExchangeIssuance is ExchangeHelpers {
    using SafeTransferLib for ERC20;

    function approveIssuanceModule(ISetToken _setToken, IIssuanceModule _issuanceModule) external {
        address[] memory components = _setToken.getComponents();
        for (uint i = 0; i < components.length; i++) {
            ERC20 component = ERC20(components[i]);
            if (component.allowance(address(this), address(_issuanceModule)) == 0) {
                component.approve(address(_issuanceModule), type(uint).max);
            }
        }
    }

    function issue(
        ISetToken _setToken,
        uint _setTokenAmount,
        ERC20 _inputToken,
        uint _maxInput,
        IIssuanceModule _issuanceModule,
        ExchangeHelpers.EXCHANGE[] memory _exchanges,
        address[] memory _intermediateTokens
    )
        external
    {
        _handleInputs(_inputToken, _maxInput);
        _getComponents(_setToken, _setTokenAmount, _exchanges, _intermediateTokens);
        _issue(_setToken, _setTokenAmount, _issuanceModule);
        _refund();
    }

    function _handleInputs(ERC20 _inputToken, uint _maxInput) internal {
        _inputToken.safeTransferFrom(msg.sender, address(this), _maxInput);
    }

    function _getComponents(
        ISetToken _setToken,
        uint _amount,
        ExchangeHelpers.EXCHANGE[] memory _exchanges,
        address[] memory _intermediateTokens
    )
        internal
    {
        (
            address[] memory components,
            uint[] memory amounts
        ) = SetLib.calculateIssuanceAmounts(_setToken, _amount);

        for (uint i = 0; i < components.length; i++) {
            _buy(_exchanges[i], components[i], amounts[i], _intermediateTokens[i]);
        }
    }

    function _issue(ISetToken _setToken, uint _amount, IIssuanceModule _issuanceModule) internal {
        _issuanceModule.issue(_setToken, _amount, msg.sender);
    }

    function _refund() internal {

    }
}