import { AdapterModel } from 'external_interactions';
import { BleClientModel } from '../model/BleClientModel';

@ObservedV2
export class ConfigDeviceViewModel {
  deviceId: string
  deviceName: string = ''
  deviceImage: ResourceStr = ''
  @Trace progress: number = 0

  private bleClientModel: BleClientModel = BleClientModel.getInstance();

  constructor(deviceId: string) {
    this.deviceId = deviceId

    let deviceInfo = this.bleClientModel.getBleDeviceInfo(deviceId)
    if (deviceInfo === undefined) {
      return
    }
    this.deviceName = deviceInfo.deviceName
    this.deviceImage = AdapterModel.getInstance().getDeviceInfo(this.deviceName).deviceInfo.deviceImage

    this.addProgress()
  }

  private addProgress() {
    this.delay(1000).then(() => {
      this.progress = 30
      this.delay(1000).then(() => {
        this.progress = 60
        this.delay(1000).then(() => {
          this.progress = 100
        })
      })
    })
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  public complete(): void {
    this.bleClientModel.setComplete(this.deviceId)
  }
}