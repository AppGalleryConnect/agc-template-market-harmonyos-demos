export class DeviceBaseInfo {
  deviceImage: ResourceStr = '';
  detailUrl: ResourceStr = '';
  briefUrl: ResourceStr = '';
  addInstructionUrl: ResourceStr = '';
}

export class DeviceInfoFromBackend {
  deviceInfo: DeviceBaseInfo = new DeviceBaseInfo();
}

export class Product {
  image: ResourceStr = '';
  name: string = '';

  constructor(image: ResourceStr, name: string) {
    this.image = image;
    this.name = name;
  }
}

export class ProductClass {
  image: ResourceStr = '';
  name: string = '';
}

export class ClassifiedProducts {
  productClass: ProductClass = new ProductClass();
  products: Product[] = [];
}

export interface ProductOnShow {
  image: ResourceStr;
  name: string;
  desc: string;
}

export class RemoteProxyModel {
  private static instance: RemoteProxyModel;
  private simulatedDeviceName = '模拟灯';
  private soundBoxName = '华为音响';

  static getInstance(): RemoteProxyModel {
    if (!RemoteProxyModel.instance) {
      RemoteProxyModel.instance = new RemoteProxyModel();
    }
    return RemoteProxyModel.instance;
  }

  public getSupportedDeviceNames(): string[] {
    return [this.simulatedDeviceName];
  }

  public getDeviceInfo(deviceName: string): DeviceInfoFromBackend {
    let info = new DeviceInfoFromBackend();
    if (deviceName.startsWith(this.soundBoxName)) {
      info.deviceInfo.deviceImage = $r('app.media.sound_box');
      info.deviceInfo.addInstructionUrl = $rawfile('addInstruction.html');
      return info;
    }
    info.deviceInfo.deviceImage = $r('app.media.light');
    info.deviceInfo.detailUrl = $rawfile('light.html');
    info.deviceInfo.briefUrl = $rawfile('lightBrief.html');
    info.deviceInfo.addInstructionUrl = $rawfile('addInstruction.html');
    return info;
  }

  public getProductsOnShow(): ProductOnShow[] {
    let products: ProductOnShow[] = [];
    let soundBox: ProductOnShow = {
      image: $r('app.media.sound_box'),
      name: '华为音响CM510',
      desc: '月激活10W+',
    };
    products.push(soundBox);

    let printer: ProductOnShow = {
      image: $r('app.media.printer'),
      name: '毕升打印机X1',
      desc: '月激活10W+',
    };
    products.push(printer);

    let watch: ProductOnShow = {
      image: $r('app.media.watch'),
      name: '华为手环8',
      desc: '月激活10W+',
    };
    products.push(watch);

    let light: ProductOnShow = {
      image: $r('app.media.light'),
      name: '智能灯',
      desc: '月激活10W+',
    };
    products.push(light);

    let earphone: ProductOnShow = {
      image: $r('app.media.earphone'),
      name: '智能蓝牙耳机',
      desc: '月激活9W+',
    };
    products.push(earphone);

    let clean: ProductOnShow = {
      image: $r('app.media.clean'),
      name: '扫地机器人',
      desc: '月激活8W+',
    };
    products.push(clean);

    let laptop: ProductOnShow = {
      image: $r('app.media.laptop'),
      name: '华为电脑Keyboard',
      desc: '月激活8W+',
    };
    products.push(laptop);

    return products;

  }

  public getAllProducts(): ClassifiedProducts[] {
    let eachClassProductsNum: number = 8;
    let allClassifiedProducts: ClassifiedProducts[] = [];
    let lightBulb = new ClassifiedProducts();
    lightBulb.productClass.image = $r('app.media.lightbulb');
    lightBulb.productClass.name = '智能灯';

    for (let j = 1; j <= eachClassProductsNum; j++) {
      let name = (j === 1) ? this.simulatedDeviceName : ('华为灯 ' + j) ;
      let product = new Product($r('app.media.light'), name);
      lightBulb.products.push(product);
    }
    allClassifiedProducts.push(lightBulb);

    let headphone = new ClassifiedProducts();
    headphone.productClass.image = $r('app.media.box');
    headphone.productClass.name = '音响';
    for (let j = 1; j <= eachClassProductsNum; j++) {
      let product = new Product($r('app.media.sound_box'), this.soundBoxName + ' ' + j);
      headphone.products.push(product);
    }
    allClassifiedProducts.push(headphone);

    return allClassifiedProducts;
  }
}