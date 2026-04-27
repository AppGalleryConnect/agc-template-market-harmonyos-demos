// 系统的分享参数模型
export interface SystemShareInfo {
  showShareMenu: boolean; // 当前页面是否允许分享，面板分享开关是否打开, 不填默认为不允许
  title?: string; // 系统分享面板标题，默认为元服务名称
  description?: string; // 系统分享面板简介，默认为元服务一句话描述
  previewUri?: string; // 分享图片缩略图，为本地文件uri，预留字段，不起作用
  parameters?: Object; // 开发者自定参数
  preview?: string; // 分享缩略图的base64编码，大小限制在32kb，太大会导致分享按钮置灰
}

/**
 * 分享参数模型
 */
@ObservedV2
export class CustomShareModel {
  @Trace id: number = 0;
  @Trace pageName: string = '';
  @Trace productId: string = '';
  @Trace productTitle: string = '';
}