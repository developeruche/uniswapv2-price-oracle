// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;


import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";




contract UniswapV2PriceOracle {
   using FixedPoint for *; // solidity does not have decimal buy default uniswap provided this solution
   uint256 public constant PERIOD = 10; // this is the wait period before the price fetch previously can be updated 

   IUniswapV2Pair public immutable pair;
   address public immutable token0;
   address public immutable token1;

   uint256 public price0CummlativeLast;
   uint256 public price1CummlativeLast;
   uint32 public blockTimestampLast;

   FixedPoint.uq112x112 public price0Average;
   FixedPoint.uq112x112 public price1Average;

   constructor (IUniswapV2Pair _pair) public {
    pair = _pair;
    token0 = _pair.token0();
    token1 = _pair.token1();
    price0CummlativeLast = _pair.price0CummlativeLast();
    price1CummlativeLast = _pair.price1CummlativeLast();
    (,, blockTimestampLast) = _pair.getReserves();
   }


   /// @dev this function would update the price0Average amd price1Average 
   function update() external {
      (
         uint256 price0Cummlative,
         uint256 price0Cummlative,
         uint32 blockTimestamp // this is the last time this pair was interacted with
      ) = UniswapV2Library.currentCummulativePrices(address(pair));
      uint256 timeElasped = blockTimestamp - blockTimestampLast;
      require(timeElasped >= PERIOD, "not time");

      price0Average = FixedPoint.uq112x112(
         unit224(
            (
               price0Cummlative - price0CummlativeLast
            ) / timeElasped
         )
      )

      price1Average = FixedPoint.uq112x112(
         unit224(
            (
               price1Cummlative - price1CummlativeLast
            ) / timeElasped
         )
      )
      
      price0CummlativeLast = price0Cummlative;
      price1CummlativeLast = price1Cummlative;
      blockTimestampLast = blockTimestamp;
   }

   /// @notice this is the function the the user would call to know how token1 when providing token0
   function consult(address _token, uint256 _amountIn) external view returns (uint256 amountOut_) {}




}
