/**
 * 新闻区域模型，定义报纸页面上的可点击区域
 */
export class NewsArea {
  // 新闻ID，用于跳转详情
  newsId: string = '';
  // 新闻标题
  title: string = '';
  // 新闻链接
  newsUrl: string = '';
  // 区域左上顶点x坐标（相对于原始图片尺寸的比例，0-1范围）
  left: number = 0;
  // 区域右上顶点x坐标（相对于原始图片尺寸的比例，0-1范围）
  right: number = 0;
  // 区域左上顶点y坐标（相对于原始图片尺寸的比例，0-1范围）
  top: number = 0;
  // 区域左下顶点y坐标（相对于原始图片尺寸的比例，0-1范围）
  bottom: number = 0;
}
    