import { AppStorageV2, UIContext } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointModel, GridRowColSetting } from 'module_weather_core';
import { City, IPosition, Province, SearchInfo } from '../types/Types';
import { Logger } from '../utils/Utils';

const TAG = '[SearchVM]';

@ObservedV2
export class SearchVM {
  @Trace text: string = '';
  searchList: SearchInfo[] = [];
  @Trace searchListSpilt: string[][] = [];
  @Trace curPostion: City = { name: '北京', code: '110100' };
  @Trace show: boolean = false;
  @Trace static popularCityList: City[] = [];
  @Trace breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  readonly searchResultColSpan: GridColColumnOption = {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  };
  readonly searchResultColOffset: GridColColumnOption = {
    sm: 0,
    md: 0,
    lg: 0,
    xl: 0,
  };
  readonly defaultCenterColSpan: GridColColumnOption = GridRowColSetting.DEFAULT_CENTER_COL_SPAN;
  readonly defaultCenterColOffset: GridColColumnOption = GridRowColSetting.DEFAULT_CENTER_COL_OFFSET;
  private static _allData: Province[] = [];
  private static _instance: SearchVM;
  itemWidth: number = 0;

  public static get instance() {
    if (!SearchVM._instance) {
      SearchVM._instance = new SearchVM();
      SearchVM._getAllData();
      SearchVM._getPopularData();
    }
    return SearchVM._instance;
  }

  public resetSearchParams() {
    this.text = '';
    this.show = false;
  }

  @Computed
  get pagePadding(): number {
    return this.breakpointModel.pagePadding;
  }

  public updateItemWidth(width: number): void {
    const GAP_COUNT = 3;
    const COLUMN_COUNT = 4;
    const GAP_SIZE = 8;
    this.itemWidth = (width - GAP_SIZE * GAP_COUNT) / COLUMN_COUNT;
  }

  public query(s: string, searchData: Province[] = SearchVM._allData) {
    const results: SearchInfo[] = [];

    for (let i = 0; i < searchData.length; i++) {
      const province = searchData[i];
      if (province.name.includes(s)) {
        if (province.city) {
          for (let j = 0; j < province.city.length; j++) {
            const city = province.city[j];
            results.push({
              province: province.name,
              city: city.name,
              code: city.code,
            });
          }
        } else {
          results.push({
            province: province.name,
            code: province.code,
          });
        }
      }

      if (province.city) {
        for (let j = 0; j < province.city.length; j++) {
          const city = province.city[j];
          if (city.name.includes(s)) {
            if (city.area) {
              for (let k = 0; k < city.area.length; k++) {
                const area = city.area[k];
                results.push({
                  province: province.name,
                  city: city.name,
                  area: area.name,
                  code: area.code,
                });
              }
            } else {
              results.push({
                province: province.name,
                city: city.name,
                code: city.code,
              });
            }
          }

          if (city.area) {
            for (let k = 0; k < city.area.length; k++) {
              const area = city.area[k];
              if (area.name.includes(s)) {
                results.push({
                  province: province.name,
                  city: city.name,
                  area: area.name,
                  code: area.code,
                });
              }
            }
          }
        }
      }
    }
    this.searchList = [...results];
    this.searchListSpilt = this.searchList.map(item => {
      let s = item.province + '·中国';
      if (item.city) {
        s = item.city + '·' + s;
      }
      if (item.area) {
        s = item.area + '·' + s;
      }
      return s.split(this.text);
    });
  }

  public getPostionFromSearchInfo(index: number) {
    const info = this.searchList[index];
    const name = info.province + (info.city ?? '') + (info.area ?? '');
    return {
      name: name,
      code: info.code,
    } as IPosition;
  }

  public checkToPop(ctx: UIContext) {
    const widthPx = ctx.getMeasureUtils().measureText({
      textContent: this.curPostion.name,
      fontSize: $r('sys.float.Body_S'),
    });
    const widthVp = ctx.px2vp(widthPx);
    if (this.itemWidth >= 12 + 2 + widthVp) {
      return false;
    }
    return true;
  }

  private static _getAllData() {
    let uiContext: UIContext = AppStorage.get('city_manage_uiContext') as UIContext
    try {
      let getJson = uiContext.getHostContext()!.resourceManager.getRawFileContentSync('all.json');
      let textDecoderOptions: util.TextDecoderOptions = { ignoreBOM: true };
      let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
      let result = textDecoder.decodeToString(getJson);
      SearchVM._allData = JSON.parse(result);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get all data. Code: ${err.code}, message: ${err.message}`);
    }
  }

  private static _getPopularData() {
    let uiContext: UIContext = AppStorage.get('city_manage_uiContext') as UIContext
    try {
      let getJson = uiContext.getHostContext()!.resourceManager.getRawFileContentSync('popular.json');
      let textDecoderOptions: util.TextDecoderOptions = { ignoreBOM: true };
      let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
      let result = textDecoder.decodeToString(getJson);
      SearchVM.popularCityList = JSON.parse(result);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get popular data. Code: ${err.code}, message: ${err.message}`);
    }
  }
}
