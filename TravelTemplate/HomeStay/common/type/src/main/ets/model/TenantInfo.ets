export class TenantInfo {
  id: number;
  appName: string;
  labelList: string[];
  banner: string | Resource;
  phone: string;
  address: string;
  position: string[];
  introduction: string;

  constructor(
    id: number = 0,
    appName: string = '',
    labelList: string[] = [],
    banner: string | Resource = '',
    phone: string = '',
    address: string = '',
    position: string[] = [],
    introduction: string = '',
  ) {
    this.id = id;
    this.appName = appName;
    this.labelList = labelList;
    this.banner = banner;
    this.phone = phone;
    this.address = address;
    this.position = position;
    this.introduction = introduction
  }
}

