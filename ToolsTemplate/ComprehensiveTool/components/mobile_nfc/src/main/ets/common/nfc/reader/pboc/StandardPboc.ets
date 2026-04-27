import { tag } from '@kit.ConnectivityKit';
import { Application, Card, CUR, PROP } from '../../Spec';
import { Response, StdTag } from '../tech/Iso7816';
import Util from '../../../Util';

export default abstract class StandardPboc {
  public static readCard(tech: tag.IsoDepTag, card: Card) {
    let tag = new StdTag(tech);
    tag.connect();
  }

  async resetTag(tag: StdTag): Promise<boolean> {
    return (await tag.selectByID(DFI_MF)).isOkay() || (await tag.selectByName(DFN_PSE)).isOkay();
  }

  abstract getApplicationId(): object

  protected getMainApplicationId(): number[] {
    return DFI_EP;
  }

  protected getCurrency(): CUR {
    return CUR.CNY;
  }

  async selectMainApplication(tag: StdTag): Promise<boolean> {
    let aid = this.getMainApplicationId();
    return ((aid.length === 2) ? await tag.selectByID(aid) : await tag.selectByName(aid)).isOkay();
  }

  async readCard(tag: StdTag, card: Card): Promise<HINT> {
    if (!await this.selectMainApplication(tag)) {
      return HINT.GONEXT;
    }

    let INFO = await tag.readBinary(SFI_EXTRA);
    let BALANCE = await tag.getBalance(0, true);
    let LOG = await this.readLog24(tag, SFI_LOG);

    let app = this.createApplication();

    this.parseBalanceDatas(app, [BALANCE]);

    this.parseInfo21(app, INFO, 4, true);

    this.parseLog24(app, [LOG]);

    this.configApplication(app);

    card.addApplication(app);

    return HINT.STOP;
  }

  parseBalanceData(data: Response): number {
    let ret = 0;
    if (data.isOkay() && data.size() >= 4) {
      let n = Util.toInt(data.getBytes(), 0, 4);
      if (n > 1000000 || n < -1000000) {
        n -= 0x80000000;
      }
      ret = n / 100.0;
    }
    return ret;
  }

  parseBalanceDatas(app: Application, data: Response[]) {
    let amount = 0;
    for (let rsp of data) {
      amount += this.parseBalanceData(rsp);
    }
    app.setProperty(PROP.BALANCE, amount.toString());
  }

  parseInfo21(app: Application, data: Response, dec: number, bigEndian: boolean) {
    if (!data.isOkay() || data.size() < 30) {
      return;
    }
    let d = data.getBytes();
    if (dec < 1 || dec > 10) {
      app.setProperty(PROP.SERIAL, Util.toHexString2(d, 10, 10));
    } else {
      let sn = bigEndian ? Util.toIntR(d, 19, dec) : Util.toInt(d, 20 - dec, dec);
      app.setProperty(PROP.SERIAL, (0xFFFFFFFF & sn).toString());
    }
    if (d[9] !== 0) {
      app.setProperty(PROP.VERSION, d[9].toString());
    }
    app.setProperty(PROP.DATE, d[20].toString().padStart(2, '0') + d[21].toString().padStart(2, '0') + '.' +
    d[22].toString().padStart(2, '0') + '.' +
    d[23].toString().padStart(2, '0') + ' - ' +
    d[24].toString().padStart(2, '0') + d[25].toString().padStart(2, '0') + '.' +
    d[26].toString().padStart(2, '0') + '.' +
    d[27].toString().padStart(2, '0'));
  }

  addLog24(r: Response, l: number[][]): boolean {
    if (!r.isOkay()) {
      return false;
    }

    let raw = r.getBytes();
    let N = raw.length - 23;
    if (N < 0) {
      return false;
    }

    for (let s = 0, e = 0; s <= N; s = e) {
      l.push(raw.slice(s, (e = s + 23)));
    }

    return true;
  }

  async readLog24(tag: StdTag, sfi: number): Promise<number[][]> {
    let ret: number[][] = [];
    let rsp = await tag.readRecord(sfi);
    if (rsp.isOkay()) {
      this.addLog24(rsp, ret);
    } else {
      for (let i = 1; i <= MAX_LOG; ++i) {
        if (!this.addLog24(await tag.readRecord(sfi, i), ret)) {
          break;
        }
      }
    }
    return ret;
  }

  parseLog24(app: Application, logs: number[][][]) {
    let ret: string[] = [];
    for (let log of logs) {
      if (log === null) {
        continue;
      }
      for (let v of log) {
        let money = Util.toInt(v, 5, 4);
        if (money > 0) {
          let s = (v[9] === TRANS_CSU || v[9] === TRANS_CSU_CPX) ? '-' : '+';
          let over = Util.toInt(v, 2, 3);
          let slog: string;
          if (over > 0) {
            slog = v[16] + v[17] + '.' + v[18] + '.' + v[19] + ' ' + v[20] + ':' + v[21] + ' ' + s +
            (money / 100.0).toFixed(2) +
              ' [o:' + (over / 100.0).toFixed(2) + '] [' + v[10] + v[11] + v[12] + v[13] + v[14] + v[15] + ']';
          } else {
            slog = v[16] + v[17] + '.' + v[18] + '.' + v[19] + ' ' + v[20] + ':' + v[21] + ' ' + s +
            (money / 100.0).toFixed(2) +
              ' [' + v[10] + v[11] + v[12] + v[13] + v[14] + v[15] + ']';
          }
          ret.push(slog);
        }
      }
    }

    if (ret.length > 0) {
      app.setProperty(PROP.TRANSLOG, ret);
    }
  }

  createApplication(): Application {
    return new Application();
  }

  configApplication(app: Application) {
    app.setProperty(PROP.ID, this.getApplicationId());
    app.setProperty(PROP.CURRENCY, this.getCurrency());
  }
};

export enum HINT {
  STOP, GONEXT, RESETANDGONEXT,
}

const DFI_MF = [0x3F, 0x00];
const DFI_EP = [0x10, 0x01];

const DFN_PSE: number[] =
  [parseInt('1'), parseInt('P'), parseInt('A'), parseInt('Y'), parseInt('.'), parseInt('S'), parseInt('Y'),
    parseInt('S'), parseInt('.'), parseInt('D'), parseInt('D'), parseInt('F'), parseInt('0'), parseInt('1')];

const SFI_EXTRA = 21;

const MAX_LOG = 10;
const SFI_LOG = 24;

const TRANS_CSU = 6;
const TRANS_CSU_CPX = 9;
