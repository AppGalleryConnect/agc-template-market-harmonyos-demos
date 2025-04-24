import { serviceList } from './service_mock_data'
import { institutions } from './institutions_mock_data'
import { inquiry } from './inquiry_mock_data'
export class CloudDbZoneWrapper {
  async queryServiceList(serviceType: string) {
    let service
    if (serviceType === 'service') {
      service = serviceList
    } else if (serviceType === 'institutions') {
      service = institutions
    }else if(serviceType === 'inquiry') {
      service = inquiry
    }
    return service
  }
}
