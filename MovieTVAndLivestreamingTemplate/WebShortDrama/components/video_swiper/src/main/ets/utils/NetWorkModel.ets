import { connection } from '@kit.NetworkKit';
/*
 * 网络状态监听模型
 */
@ObservedV2
export class NetWorkModel {
  @Trace netCon: connection.NetConnection | null = null;
  @Trace isCellular: boolean = false;
  @Trace isNetAvailable: boolean = false;
  // @Trace isShowController: boolean = false;
  @Trace isShowGoOn: boolean = false;
  @Trace reInit: boolean = false
  @Trace inDetailPage: boolean = false
  @Trace noReInit: boolean = false
}