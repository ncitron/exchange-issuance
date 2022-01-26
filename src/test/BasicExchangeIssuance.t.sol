// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "forge-std/stdlib.sol";

import { BasicExchangeIssuance } from "../BasicExchangeIssuance.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ExchangeHelpers } from "../lib/ExchangeHelpers.sol";
import { IIssuanceModule } from "../interfaces/IIssuanceModule.sol";
import { ISetToken } from "../interfaces/ISetToken.sol";

contract BasicExchangeIssuanceTest is DSTest {
    using stdStorage for StdStorage;

    StdStorage stdstore;

    ERC20 bed = ERC20(0x2aF1dF3AB0ab157e1E2Ad8F88A7D04fbea0c7dc6);
    ERC20 weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IIssuanceModule basicIssuance = IIssuanceModule(0xd8EF3cACe8b4907117a45B0b125c68560532F94D);

    ExchangeHelpers.EXCHANGE[] exchanges;
    address[] intermediates;

    BasicExchangeIssuance exchangeIssuance;

    function setUp() public {
        stdstore.target(address(weth)).sig(weth.balanceOf.selector).with_key(address(this)).checked_write(100 ether);
        stdstore.target(address(bed)).sig(bed.balanceOf.selector).with_key(address(this)).checked_write(100 ether);

        exchangeIssuance = new BasicExchangeIssuance();
        exchangeIssuance.approveIssuanceModule(ISetToken(address(bed)), basicIssuance);
        exchangeIssuance.approveSetToken(ISetToken(address(bed)));

        weth.approve(address(exchangeIssuance), type(uint).max);
        bed.approve(address(exchangeIssuance), type(uint).max);

        exchanges = new  ExchangeHelpers.EXCHANGE[](3);
        exchanges[0] = ExchangeHelpers.EXCHANGE.UNI_V2;
        exchanges[1] = ExchangeHelpers.EXCHANGE.UNI_V2;
        exchanges[2] = ExchangeHelpers.EXCHANGE.NONE;

        intermediates = new address[](3);
        intermediates[0] = address(0);
        intermediates[1] = address(0);
        intermediates[2] = address(0);
    }

    function testIssueWeth() public {

        uint initSetBalance = bed.balanceOf(address(this));
        uint initWethBalance = weth.balanceOf(address(this));

        exchangeIssuance.issue(
            ISetToken(address(bed)),
            1 ether,
            weth,
            1 ether,
            basicIssuance,
            exchanges,
            intermediates
        );

        uint finalSetBalance = bed.balanceOf(address(this));
        uint finalWethBalance = weth.balanceOf(address(this));

        assertEq(finalSetBalance - initSetBalance, 1 ether);
        assertLt(finalWethBalance, initWethBalance);
    }

    function testFailIssueWethSlippage() public {
        exchangeIssuance.issue(
            ISetToken(address(bed)),
            100 ether,
            weth,
            1 ether,
            basicIssuance,
            exchanges,
            intermediates
        );
    }

    function testRedeemWeth() public {

        uint initSetBalance = bed.balanceOf(address(this));
        uint initWethBalance = weth.balanceOf(address(this));

        exchangeIssuance.redeem(
            ISetToken(address(bed)),
            1 ether,
            weth,
            0,
            basicIssuance,
            exchanges,
            intermediates
        );

        uint finalSetBalance = bed.balanceOf(address(this));
        uint finalWethBalance = weth.balanceOf(address(this));

        assertEq(initSetBalance - finalSetBalance, 1 ether);
        assertGt(finalWethBalance, initWethBalance);
    }

    function testFailRedeemWethSlippage() public {
        exchangeIssuance.redeem(
            ISetToken(address(bed)),
            1 ether,
            weth,
            100 ether,
            basicIssuance,
            exchanges,
            intermediates
        );
    }
}
