
/**
 * 通用方法类
 */
export class Utils {
  /**
   * 随机打乱数组
   * @param array
   * @returns
   */
  public static shuffleArray<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      // 生成 0 到 i 之间的随机索引
      const j = Math.floor(Math.random() * (i + 1));

      // 交换当前元素与随机位置的元素
      const temp = array[i];
      array[i] = array[j]
      array[j] = temp;
    }
    return array;
  }

  /**
   * 随机生成推荐id
   * @returns
   */
  public static randomRecommendId() {
    return Math.floor(Math.random() * (12 - 6 + 1)) + 6;
  }

  /**
   * 随机生成文章id
   * @returns
   */
  public static randomArticleId() {
    return Math.floor(Math.random() * (100 - 20 + 1)) + 20;
  }
}