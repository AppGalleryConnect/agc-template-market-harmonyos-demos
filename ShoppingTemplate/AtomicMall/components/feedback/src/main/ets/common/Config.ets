export class Config {
  /**
   * 启用 Mock 模式
   *
   * 该设置启用后，问题反馈相关请求将被 Axios 适配器拦截，返回 Mock 数据
   */
  public static readonly IS_MOCK_ADAPTER_ENABLE: boolean = true;

  /**
   * 问题描述文本可输入的最大字数
   */
  public static readonly DESC_TEXT_MAX_LENGTH: number = 150;

  /**
   * 问题描述文本需要输入的最小字数
   */
  public static readonly DESC_TEXT_MIN_LENGTH: number = 10;

  /**
   * 可选择的最大图片数量 (可设置的值上限为500)
   */
  public static readonly MAX_IMAGE_COUNT: number = 6;

  /**
   * 请求基础 URL, 例如 https://127.0.0.1:8443
   */
  public static readonly API_BASE_URL: string = '';

  /**
   * 请求超时时长
   */
  public static readonly REQUEST_TIMEOUT: number = 8 * 1000;
}

export const LOG_TAG:string = '[Feedback]';
