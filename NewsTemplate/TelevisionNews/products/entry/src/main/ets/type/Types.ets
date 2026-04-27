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
  @Trace avId: string = '';
}


/**
 * 卡片图片模型
 */
export class FormDataClass {
  imgName: string = '';
  formImages: Record<string, number> = {};
}