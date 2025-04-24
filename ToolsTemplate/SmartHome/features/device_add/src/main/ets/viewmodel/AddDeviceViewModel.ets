import { AdapterModel } from 'external_interactions';

export class AddDeviceViewModel {
  deviceNamesToScan: string[] = []

  constructor() {
    this.deviceNamesToScan = AdapterModel.getInstance().getSupportedDeviceNames();
  }
}