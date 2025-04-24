import { AdapterModel } from 'external_interactions';

export class AddInstructionViewModel {
  deviceName: string
  deviceImage: ResourceStr
  addInstructionUrl: ResourceStr

  constructor(deviceName: string) {
    this.deviceName = deviceName
    let deviceInfoFromBackend = AdapterModel.getInstance().getDeviceInfo(deviceName)
    this.deviceImage = deviceInfoFromBackend.deviceInfo.deviceImage
    this.addInstructionUrl = deviceInfoFromBackend.deviceInfo.addInstructionUrl
  }
}