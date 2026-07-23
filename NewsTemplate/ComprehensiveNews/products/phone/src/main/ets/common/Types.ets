/**
 * 服务卡片-数据模型
 */
export class FormCardData {
  data: string = '';
}

/**
 * 服务卡片-跳转模型
 */
@ObservedV2
export class FormCardRouter {
  @Trace id: number = 0;
  @Trace pageUrl: string = '';
  @Trace newsId: string = '';
  @Trace newsType: number = 0;
}

/**
 * AppLinking-跳转模型
 */
@ObservedV2
export class AppLinkingRouter {
  @Trace id: number = 0;
  @Trace newsId: string = '';
  @Trace newsType: number = 0;
}

/**
 * 快捷方式-跳转模型
 */
@ObservedV2
export class ShortcutRouter {
  @Trace pageName: string = '';
}