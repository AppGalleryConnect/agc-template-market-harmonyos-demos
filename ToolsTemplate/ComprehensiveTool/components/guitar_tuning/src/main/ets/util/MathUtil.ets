/**
 * 处理波动数组（含少数极端误差），计算集中趋势目标值
 * @param dataArr 待处理的数值数组
 * @param method 计算方法：'median'（中位数法）、'trimmedMean'（修剪均值法）、'filteredMean'（去极端值后均值法）
 * @param trimRatio 修剪均值法的剔除比例（默认0.05，即前后各5%，需在0~0.2区间内，避免剔除过多数据）
 * @returns 计算得出的集中趋势目标值（保留2位小数）
 */
export function calculateCentralValue(
  dataArr: number[],
  method: 'median' | 'trimmedMean' | 'filteredMean' = 'filteredMean',
  trimRatio: number = 0.05,
): number {
  // 深拷贝数组并排序
  const sortedArr = [...dataArr].sort((a, b) => a - b);
  let result: number = 0;

  switch (method) {
    case 'median':
      const midIndex = Math.floor(sortedArr.length / 2);
      // 数组长度为奇数：取中间值；偶数：取中间两个值的平均值
      result = sortedArr.length % 2 === 1
        ? sortedArr[midIndex]
        : (sortedArr[midIndex - 1] + sortedArr[midIndex]) / 2;
      break;
    case 'trimmedMean':
      const trimCount = Math.floor(sortedArr.length * trimRatio);
      // 剔除前后trimCount个极端值，取剩余数据计算均值
      const filteredTrimArr = sortedArr.slice(trimCount, sortedArr.length - trimCount);
      result = filteredTrimArr.reduce((sum, val) => sum + val, 0) / filteredTrimArr.length;
      break;
    default:
      const n = sortedArr.length;
      // 计算四分位Q1（下四分位）和Q3（上四分位）
      const q1 = sortedArr[Math.ceil(n * 0.25) - 1];
      const q3 = sortedArr[Math.floor(n * 0.75) - 1];
      // 计算四分位距IQR，异常值判定标准：小于Q1-1.5*IQR 或 大于Q3+1.5*IQR
      const iqr = q3 - q1;
      const lowerBound = q1 - 1.5 * iqr;
      const upperBound = q3 + 1.5 * iqr;
      // 过滤异常值后计算均值
      const filteredIqrArr = sortedArr.filter(val => val >= lowerBound && val <= upperBound);
      // 兜底：若过滤后数据过少（<3），则用原数组中位数替代（避免计算无效均值）
      result = filteredIqrArr.length >= 3
        ? filteredIqrArr.reduce((sum, val) => sum + val, 0) / filteredIqrArr.length
        : calculateCentralValue(sortedArr, 'median');
      break;
  }

  // 保留2位小数，避免浮点数精度问题导致的数值过长
  return Number(result.toFixed(2));
}