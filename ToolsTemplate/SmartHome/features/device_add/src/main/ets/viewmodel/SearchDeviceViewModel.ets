import { AdapterModel } from 'external_interactions';

export class SearchDeviceViewModel {
  deviceName: string
  deviceImage: ResourceStr

  constructor(deviceName: string) {
    this.deviceName = deviceName
    let deviceInfoFromBackend = AdapterModel.getInstance().getDeviceInfo(deviceName)
    this.deviceImage = deviceInfoFromBackend.deviceInfo.deviceImage
  }
}