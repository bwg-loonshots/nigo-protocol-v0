function avg(arr) {
  const sum = arr.reduce((a, v) => a + v);
  return Math.round(sum/arr.length);
}
const historicalBlocks = 20;
web3.eth.getFeeHistory(historicalBlocks, "pending", [1, 50, 99]).then((feeHistory) => {
  const blocks = formatFeeHistory(feeHistory, false);
  const slow    = avg(blocks.map(b => b.priorityFeePerGas[0]));
  const average = avg(blocks.map(b => b.priorityFeePerGas[1]));
  const fast    = avg(blocks.map(b => b.priorityFeePerGas[2]));
web3.eth.getBlock("pending").then((block) => {
    const baseFeePerGas = Number(block.baseFeePerGas);
    console.log("Manual estimate:", {
      slow: slow + baseFeePerGas,
      average: average + baseFeePerGas,
      fast: fast + baseFeePerGas,
    });
  });
});