import { UtilLog } from '@hw-agconnect/util-log';
import { UIContext, window } from '@kit.ArkUI';
import { connection, statistics } from '@kit.NetworkKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { netQuality } from '@kit.NetworkBoostKit';
import { fileIo } from '@kit.CoreFileKit';
import { NetworkType } from '../types/NetworkType';
import { MeasureStatus } from '../constants/Enum';
import { Logger } from '../utils/Logger';
import { alert } from '../utils/Dialog';

const TAG = '[MeasureVM]';

@ObservedV2
export class MeasureVM {
  /** 相关参数 **/
  // 测速状态
  @Trace status: MeasureStatus = MeasureStatus.WAITING;
  // 有网络
  @Trace hasNet: boolean = false;
  // 网络类型
  @Trace type: NetworkType = NetworkType.UNDEFINED;
  // 网络地址
  @Trace address: string = '';
  // 时延
  @Trace rttMs: number = 0;
  @Trace curValue: number = 0;
  @Trace desc: string = '';
  /** 下载相关 **/
  @Trace downBytes: number = 0;
  @Trace averageDownData: number = 0;
  downData: number[] = [];
  downloadTask: request.DownloadTask | undefined = undefined;
  // todo: 替换下载url
  downloadUrl: string = 'downloadUrl';
  @Trace uploading: boolean = false;
  @Trace upBytes: number = 0;
  @Trace averageUpData: number = 0;
  upData: number[] = [];
  uploadTask: request.UploadTask | undefined = undefined;
  // todo: 替换上传url
  uploadUrl: string = 'uploadUrl';
  /** 其他参数 **/
  limit: number = 10;
  fileName: string = '';
  startBytes: number = 0;
  endBytes: number = 0;
  netCon: connection.NetConnection = connection.createNetConnection();
  /** 唯一实例 **/
  private static _instance: MeasureVM;

  public static get instance() {
    if (!MeasureVM._instance) {
      MeasureVM._instance = new MeasureVM();
    }
    return MeasureVM._instance;
  }

  public in(uiContext: UIContext) {
    this.status = MeasureStatus.WAITING;
    this.hasNet = false;
    this.type = NetworkType.UNDEFINED;
    this.address = '';
    this._register(uiContext);
    this.setStatusBarContentColor('#ffffff', uiContext);
  }

  public out() {
    this._unregister();
  }

  public setStatusBarContentColor(color: string, uiContext: UIContext) {
    try {
      window.getLastWindow(uiContext.getHostContext()).then(win => {
        win.setWindowSystemBarProperties({ statusBarContentColor: color });
      });
    } catch (e) {
      UtilLog.error(`setStatusBarContentColor failed : ${JSON.stringify(e)}`);
    }
  }

  public beginMeasure(uiContext: UIContext) {
    if (!this.hasNet) {
      alert('网络不可用', '当前网络不可用,请检查网络', uiContext);
      return;
    }
    if (this.status === MeasureStatus.GOING) {
      uiContext.getPromptAction().showToast({ message: '正在测速中...' });
      return;
    }

    this.curValue = 0;
    this.rttMs = -1;
    this.desc = '';
    this.averageDownData = -1;
    this.averageUpData = -1;
    this.downData.length = 0;
    this.upData.length = 0;
    this.uploading = false;

    try {
      this.status = MeasureStatus.GOING;
      this._requestDownload(uiContext.getHostContext() as Context);
    } catch (err) {
      Logger.error(TAG, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  public stopMeasure() {
    this.curValue = 0;
    if (this.downloadTask) {
      this.downloadTask.delete((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to remove the download task. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.downloadTask = undefined;
      });
    }

    if (this.uploadTask) {
      this.uploadTask.delete((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to remove the upload task. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.uploadTask = undefined;
      });
    }

    try {
      netQuality.off('netQosChange');
      this.status = MeasureStatus.WAITING;
    } catch (err) {
      Logger.info(TAG, JSON.stringify(err, null, 2));
    }
  }

  private _requestDownload(context: Context) {
    this.fileName = Date.now().toString() + '.jpeg';
    try {
      request.downloadFile(context, { url: this.downloadUrl, filePath: context.cacheDir + '/' + this.fileName })
        .then((data: request.DownloadTask) => {
          this.downloadTask = data;
          this._calculateBytes(true, true);
          netQuality.on('netQosChange', (list: netQuality.NetworkQos[]) => {
            list.forEach(qos => {
              if (this.downData.length === this.limit) {
                this.averageDownData = this._calculateAverage(this.downData);
                if (this.downloadTask) {
                  this.curValue = 0;
                  this._calculateBytes(true, false);
                  this.downloadTask.delete().then(() => {
                    const timeId = setTimeout(() => {
                      this._requestUpload(context);
                      clearTimeout(timeId);
                    }, 1000);
                  });
                  this.downloadTask = undefined;
                }
                return;
              }
              if (qos.linkDownRate / 1000000 < 1) {
                return;
              }
              this.curValue = qos.linkDownRate / 1000000;
              this.downData.push(qos.linkDownRate / 1000000);
              if (qos.rttMs > 0 && this.rttMs < 0) {
                this.rttMs = qos.rttMs;
              }
            });
          });
        })
        .catch((err: BusinessError) => {
          this.stopMeasure();
          Logger.error(TAG, `Failed to request the download. Code: ${err.code}, message: ${err.message}`);
        });
    } catch (err) {
      const code = (err as BusinessError).code;
      if (code === 401 && this.downloadUrl === 'downloadUrl') {
        // 本判断仅用于mock下载文件,替换为下载接口后删除
        const timeId1 = setInterval(() => {
          if (this.downData.length === this.limit) {
            this.averageDownData = this._calculateAverage(this.downData);
            this.curValue = 0;
            const rand1 = cryptoFramework.createRandom();
            this.downBytes = rand1.generateRandomSync(1).data[0] % 5 + 200;
            this.downloadTask = undefined;
            const timeId2 = setTimeout(() => {
              this._requestUpload(context);
              clearTimeout(timeId2);
            }, 1000);
            clearInterval(timeId1);
            return;
          }
          const mockData = [91.4, 230.7, 197.3, 291.2, 246.2, 262.3, 278.1, 284.2, 239.3, 265.4];
          const rand2 = cryptoFramework.createRandom();
          this.curValue = mockData[this.downData.length] + rand2.generateRandomSync(1).data[0] % 5;
          if (this.rttMs < 0) {
            this.rttMs = 10 + rand2.generateRandomSync(1).data[0] % 15;
          }
          this.downData.push(this.curValue);
        }, 1000);
        return;
      }
      this.stopMeasure();
      Logger.error(TAG, `Failed to request the download. err: ${JSON.stringify(err)}`);
    }
  }

  private _requestUpload(context: Context) {
    if (this.downloadUrl !== 'downloadUrl' && !fileIo.accessSync(context.cacheDir + '/' + this.fileName)) {
      this.stopMeasure();
      return;
    }
    // todo:调整对应上传配置
    let uploadConfig: request.UploadConfig = {
      url: this.uploadUrl,
      header: {},
      method: 'POST',
      files: [{
        filename: this.fileName.split('.')[0],
        name: 'file',
        uri: `internal://cache/${this.fileName}`,
        type: 'image/jpeg',
      }],
      data: [],
    };
    try {
      request.uploadFile(context, uploadConfig).then((data: request.UploadTask) => {
        this.uploading = true;
        this.uploadTask = data;
        this._calculateBytes(false, true);
        netQuality.on('netQosChange', (list: netQuality.NetworkQos[]) => {
          list.forEach(qos => {
            if (this.upData.length === this.limit) {
              this.averageUpData = this.averageUpData = this._calculateAverage(this.upData);
              this.desc = this._getDesc();
              if (this.uploadTask) {
                this.curValue = 0;
                this._calculateBytes(false, false);
                this.uploadTask.delete();
                this.uploadTask = undefined;
                this.status = MeasureStatus.OVER;
                fileIo.unlink(context.cacheDir + '/' + this.fileName);
              }
              try {
                netQuality.off('netQosChange');
              } catch (err) {
                Logger.info(TAG, JSON.stringify(err, null, 2));
              }
              return;
            }
            this.curValue = qos.linkDownRate / 1000000;
            this.upData.push(qos.linkUpRate / 1000000);
          });
        });

      }).catch((err: BusinessError) => {
        this.stopMeasure();
        Logger.error(TAG, `Failed to request the upload. Code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      const code = (err as BusinessError).code;
      if (code === 401 && this.uploadUrl === 'uploadUrl') {
        this.uploading = true;
        // 本判断仅用于mock上传文件,替换为真实上传接口后删除
        const timeId = setInterval(() => {
          if (this.upData.length === this.limit) {
            this.averageUpData = this._calculateAverage(this.upData);
            this.desc = this._getDesc();
            this.curValue = 0;
            const rand1 = cryptoFramework.createRandom();
            this.upBytes = rand1.generateRandomSync(1).data[0] % 5 + 20;
            this.uploadTask = undefined;
            this.status = MeasureStatus.OVER;
            clearInterval(timeId);
            try {
              netQuality.off('netQosChange');
            } catch (err) {
              Logger.info(TAG, JSON.stringify(err, null, 2));
            }
            return;
          }
          const mockData = [8.2, 15.6, 25.0, 35.3, 40.1, 35.1, 30.2, 25.7, 15.5, 16.4];
          const rand2 = cryptoFramework.createRandom();
          this.curValue = mockData[this.upData.length] + rand2.generateRandomSync(1).data[0] % 2;
          this.upData.push(this.curValue);
        }, 1000);
        return;
      }
      this.stopMeasure();
      Logger.error(TAG, `Failed to request the download. err: ${JSON.stringify(err)}`);
    }
  }

  private _register(uiContext: UIContext) {
    this.netCon.register((error) => {
      if (error) {
        Logger.error(TAG, `network register error: ${JSON.stringify(error)}`);
      }
    });
    // 订阅网络不可用事件。
    this.netCon.on('netUnavailable', () => {
      this.hasNet = false;
      Logger.info(TAG, 'netUnavailable');
    });
    // 订阅网络能力变化事件。
    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      this._getNetwork(data, uiContext);
      Logger.info(TAG, `netCapabilitiesChange, get data: ${JSON.stringify(data)}`);
    });
    // 订阅网络连接信息变化事件。
    this.netCon.on('netConnectionPropertiesChange', (data: connection.NetConnectionPropertyInfo) => {
      const connectionProperties = data.connectionProperties;
      const dnses = connectionProperties.dnses;
      this.address = dnses[0].address;
      Logger.info(TAG, `netConnectionPropertiesChange, get data: ${JSON.stringify(data)}`);
    });
    // 订阅网络丢失事件。
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      this.hasNet = false;
      if (this.status === MeasureStatus.GOING) {
        this.stopMeasure();
      }
      Logger.info(TAG, `netLost, get data: ${JSON.stringify(data)}`);
    });
  }

  private _unregister() {
    this.netCon.unregister((error) => {
      if (error) {
        Logger.error(TAG, `unregister network: ${JSON.stringify(error)}`);
      }
    });
    try {
      netQuality.off('netQosChange');
    } catch (err) {
      Logger.info(TAG, JSON.stringify(err, null, 2));
    }
  }


  private _getNetwork(data: connection.NetCapabilityInfo, uiContext: UIContext) {
    let netHandle: connection.NetHandle;
    let netCapability: connection.NetCapabilities;
    if (data) {
      netHandle = data.netHandle;
      netCapability = data.netCap;
    } else {
      netHandle = connection.getDefaultNetSync();
      netCapability = connection.getNetCapabilitiesSync(netHandle);
    }
    if (netHandle.netId < 100) {
      this.hasNet = false;
      return;
    }
    const cap = netCapability.networkCap || [];
    if (cap.includes(connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY)) {
      return;
    }
    if (cap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
      if (this.status === MeasureStatus.GOING) {
        alert('网络变化', '当前网络发生变化,请重新测速', uiContext);
        this.stopMeasure();
      }
      this.hasNet = true;
      if (netCapability.bearerTypes[0] === 0) {
        this.type = NetworkType.CELLULAR;
      } else if (netCapability.bearerTypes[0] === 1) {
        this.type = NetworkType.WIFI;
      }
    } else {
      this.hasNet = false;
    }
  }

  private _calculateBytes(isDown: boolean, isStart: boolean) {
    try {
      let promise: Promise<number>;
      if (isDown) {
        promise =
          this.type === NetworkType.WIFI ? statistics.getIfaceRxBytes('wlan0') : statistics.getCellularRxBytes();
      } else {
        promise =
          this.type === NetworkType.WIFI ? statistics.getIfaceTxBytes('wlan0') : statistics.getCellularTxBytes();
      }
      promise.then(stats => {
        if (isStart) {
          this.startBytes = stats;
        } else {
          this.endBytes = stats;
          if (isDown) {
            this.downBytes = (this.endBytes - this.startBytes) / 1000000;
          } else {
            this.upBytes = (this.endBytes - this.startBytes) / 1000000;
          }
        }
      })
        .catch((err: BusinessError) => {
          Logger.error(TAG,
            'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
        });
    } catch (e) {
      UtilLog.error(`calculateBytes failed: ${JSON.stringify(e)}`);
    }
  }

  private _calculateAverage(numbers: number[]): number {
    if (numbers.length === 0) {
      return 0;
    }
    const sum = numbers.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
    return sum / numbers.length;
  }

  private _getDesc() {
    let max = Math.max(0, ...this.upData);
    max = Math.max(max, ...this.downData);

    let prevLimit = 0;
    let currentLimit = 5;
    let exponent = 0;
    let isFiveMultiple = true;

    while (true) {
      if (max > prevLimit && max <= currentLimit) {
        return '您的网速相当于' + currentLimit + 'M带宽';
      }
      prevLimit = currentLimit;
      if (isFiveMultiple) {
        currentLimit = 10 * Math.pow(10, exponent);
        isFiveMultiple = false;
      } else {
        exponent++;
        currentLimit = 5 * Math.pow(10, exponent);
        isFiveMultiple = true;
      }
    }
  }
}