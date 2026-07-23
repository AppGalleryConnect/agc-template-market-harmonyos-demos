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
  @Trace params: string = '';
}

/**
 * 服务卡片-跳转模型
 */
@ObservedV2
export class FormCardParams {
  @Trace source: string = '';
  @Trace message: string = '';
}
