import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, RealTimeWeather, WeatherUtils } from 'module_weather_core';
import { IPosition } from '../types/Types';
import { Loading } from '../utils/Loading';
import { PositionUtl } from '../utils/PostionUtil';
import { CityManager } from '../utils/Utils';

@ObservedV2
export class ManagedVM {
  @Trace edit: boolean = false;
  @Trace postionList: IPosition[] = [];
  @Trace minePosition: IPosition = { name: '北京', code: '110100' };
  @Trace mineWeather: RealTimeWeather | undefined;
  @Trace otherWeathers: RealTimeWeather[] = [];
  @Trace breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private static _instance: ManagedVM;

  public static get instance() {
    if (!ManagedVM._instance) {
      ManagedVM._instance = new ManagedVM();
    }
    return ManagedVM._instance;
  }

  public init(ctx: UIContext) {
    this.resetSelectedParams();
    Loading.init(ctx);
    Loading.open();
    Promise.all([this._getMinePositionAndWeather(), this._getOtherPostionAndWeather()]).then(() => {
      Loading.close();
    });
  }

  public resetSelectedParams() {
    this.edit = false;
    this.minePosition = { name: '北京', code: '110100' };
    this.mineWeather = undefined;
    this.otherWeathers = [];
  }

  @Computed
  get pagePadding(): number {
    return this.breakpointModel.pagePadding;
  }

  public setEdit(edit: boolean): void {
    this.edit = edit;
  }

  public addPosition(newPosition: IPosition): void {
    if (this.postionList.findIndex(item => item.code === newPosition.code) !== -1) {
      return;
    }
    WeatherUtils.getRealTimeWeathers([newPosition.code]).then(res => {
      this.postionList.push(newPosition);
      this.otherWeathers.push(res[0]);
    });
  }

  private async _getMinePositionAndWeather() {
    this.minePosition = await CityManager.applyLocationPermission();
    this.mineWeather = (await WeatherUtils.getRealTimeWeathers([this.minePosition.code]))[0];
  }

  private async _getOtherPostionAndWeather() {
    this.otherWeathers = await WeatherUtils.getRealTimeWeathers(this.postionList.map(item => item.code));
  }
}
