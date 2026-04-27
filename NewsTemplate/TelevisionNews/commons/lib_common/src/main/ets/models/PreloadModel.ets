import { AvModel } from 'lib_tv_apis';

/**
 * 预加载-数据模型
 */
@ObservedV2
export class PreloadInfo {
  @Trace data: AvModel[] = [];
  @Trace status: PreloadStatus = PreloadStatus.INIT;
}

/**
 * INIT 初始化
 * FAILED 失败
 * SUCCESS 成功
 */
export enum PreloadStatus {
  INIT = 'init',
  FAILED = 'failed',
  SUCCESS = 'success'
}