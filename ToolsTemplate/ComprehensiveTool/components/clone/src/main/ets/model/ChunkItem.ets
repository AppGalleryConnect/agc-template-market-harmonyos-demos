export interface ChunkItem {
  /** 分片索引 */
  index: number;

  /** 分片数据 */
  data: ArrayBuffer;

  /** 分片大小 */
  size: number;

  /** 是否为最后一个分片 */
  isLast: boolean;
}