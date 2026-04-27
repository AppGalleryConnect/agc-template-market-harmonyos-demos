export interface MarkOptions {
  /**
   * 存储文件名
   */
  file: string;

  /**
   * 最近编辑时间
   */
  time: string;

  /**
   * 水印文字
   */
  text: string;

  /**
   * 水印大小
   */
  size: number;

  /**
   * 水印颜色
   */
  color: string;

  /**
   * 水印透明度
   */
  opacity: number;

  /**
   * 水印间距
   */
  space: number;

  /**
   * 水印角度
   */
  rotate: number;
}