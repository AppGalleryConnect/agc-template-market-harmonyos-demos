import { tag } from '@kit.ConnectivityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import Util from '../../Util';
import { APP, Application, Card, CUR, PROP } from '../Spec';
import { ReadResponse, ServiceCode, Tag } from './tech/FeliCa';

export default class FeliCaReader {
  static async readCard(tech: tag.NfcFTag, card: Card) {

    let tag: Tag = new Tag(tech);

    tag.connect();
    if (tech.isConnected()) {
      card.addApplication(await FeliCaReader.readApplication(tag, FeliCaReader.SYS_OCTOPUS));
      try {
        card.addApplication(await FeliCaReader.readApplication(tag, FeliCaReader.SYS_SZT));
      } catch (e) {
        UtilLog.error(0xff00, 'MobileNFC', 'read fail: ' + JSON.stringify(e));
      }

      tag.close();
    }
  }

  static SYS_SZT = 0x8005;
  static SYS_OCTOPUS = 0x8008;
  static SRV_SZT = 0x0118;
  static SRV_OCTOPUS = 0x0117;

  static async readApplication(tag: Tag, system: number): Promise<Application | undefined> {

    let scode: ServiceCode;
    let app: Application;
    if (system === FeliCaReader.SYS_OCTOPUS) {
      app = new Application();
      app.setProperty(PROP.ID, APP.OCTOPUS);
      app.setProperty(PROP.CURRENCY, CUR.HKD);
      scode = new ServiceCode(FeliCaReader.SRV_OCTOPUS);
    } else if (system === FeliCaReader.SYS_SZT) {
      app = new Application();
      app.setProperty(PROP.ID, APP.SHENZHENTONG);
      app.setProperty(PROP.CURRENCY, CUR.CNY);
      scode = new ServiceCode(FeliCaReader.SRV_SZT);
    } else {
      return undefined;
    }

    app.setProperty(PROP.SERIAL, tag.getIDm().toString());
    app.setProperty(PROP.PARAM, tag.getPMm().toString());

    await tag.polling(system);

    let data: number[] = [0, 0, 0]

    let p = 0;
    for (let i = 0; p < data.length; ++i) {
      let r: ReadResponse = await tag.readWithoutEncryption(i, scode);
      if (!r.isOkey()) {
        break;
      }

      data[p++] = (Util.toInt(r.getBlockData(), 0, 4) - 350) / 10.0;
    }

    if (p !== 0) {
      app.setProperty(PROP.BALANCE, FeliCaReader.parseBalance(data).toString());
    } else {
      app.setProperty(PROP.BALANCE, (0).toString());
    }

    return app;
  }

  static parseBalance(value: number[]): number {
    let balance = 0;
    for (let v of value) {
      balance += v;
    }
    return balance;
  }
}