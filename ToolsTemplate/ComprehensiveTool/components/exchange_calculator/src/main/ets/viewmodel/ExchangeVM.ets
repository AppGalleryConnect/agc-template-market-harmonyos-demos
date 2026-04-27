import { UtilLog } from '@hw-agconnect/util-log';
import { window } from '@kit.ArkUI';
import { ICurrencyData } from '../model/Types';
import { Currency } from '../httpsmock/Exchange';
import { ExchangeServiceApi } from '../https/apis/ExchangeService';

@ObservedV2
export class ExchangeVM {
  @Trace editFlag: boolean = false;
  @Trace updateTime: string = '';
  @Trace results: string[] = [];
  @Trace exchangeData: ICurrencyData[] = [];
  @Trace keyboardShow: boolean = false;
  private _keyboardHeightChangeCallback = (data: number) => {
    this.keyboardShow = data ? true : false;
  };

  public onKeyboardChange(uiContext: UIContext) {
    try {
      window.getLastWindow(uiContext.getHostContext())
        .then(currentWindow => currentWindow.on('keyboardHeightChange', this._keyboardHeightChangeCallback));
    } catch (e) {
      UtilLog.error(`onKeyboardChange failed with error ${JSON.stringify(e)}`);
    }
  }

  public offKeyboardChange(uiContext: UIContext) {
    try {
      window.getLastWindow(uiContext.getHostContext())
        .then(currentWindow => currentWindow.off('keyboardHeightChange', this._keyboardHeightChangeCallback));
    } catch (e) {
      UtilLog.error(`offKeyboardChange failed with error ${e}`)
    }
  }

  private static _instance: ExchangeVM;

  public static get instance() {
    if (!ExchangeVM._instance) {
      ExchangeVM._instance = new ExchangeVM();
    }
    return ExchangeVM._instance;
  }

  public getExchangeInfo() {
    ExchangeServiceApi.queryExchangeList().then((resp) => {
      this.updateTime = this.getCurrentTimeStr(resp.updateTime);
      this.exchangeData = resp.rates.map((item: Currency) => {
        return {
          bankConversionPri: item.rate,
          name: item.name,
          country: item.country,
          pic: $r(`app.media.${item.country}`),
        } as ICurrencyData;
      });
    });
  }

  public resetResults() {
    this.results = Array.from<string>({ length: this.exchangeData.length }).fill('');
  }

  public calcBaseValue(newText: string, index: number) {
    if (!newText) {
      this.resetResults();
      return;
    }
    let rate = Number(this.exchangeData[index].bankConversionPri);
    const baseValue = rate / 100 * Number(newText);
    this.results = this.exchangeData.map((item, i) => {
      if (i !== index) {
        return (100 / Number(item.bankConversionPri) * baseValue).toFixed(3).toString();
      } else {
        return newText;
      }
    });
    this.editFlag = false;
  }

  public getCurrentTimeStr(timeStamp: number) {
    const date = new Date(timeStamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }
}