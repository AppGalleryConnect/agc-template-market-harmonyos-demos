import { BusinessError } from '@kit.BasicServicesKit';

export interface TcpCallback {
  /**
   * 初始化成功
   * @param port
   */
  onPrepared?: (port?: number) => void;

  /**
   * 失败
   * @param err
   */
  onFailed?: (err: BusinessError | string) => void;

  /**
   * 连接成功回调
   */
  onConnected?: () => void;

  /**
   * 关闭
   */
  onClose?: () => void;
}