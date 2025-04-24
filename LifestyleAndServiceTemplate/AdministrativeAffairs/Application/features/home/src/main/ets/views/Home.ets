import {
  GridBanner,
  HomeServiceList,
  EmitterEventId,
  HotService,
  Constants,
  PermissionRequestUtils,
  getCurrentLocation,
} from 'common'
import { BannerGrid } from '../components/BannerGrid';
import { HotServices } from '../components/HotServices';
import { emitter } from '@kit.BasicServicesKit';
import { InstitutionPersonalCard } from '../components/InstitutionPersonalCard';
import { ConvenientService, ServiceTitle } from 'components';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct Home {
  @Local gridBanner: GridBanner[] = [];
  @Local hotServices: HotService[] = [];
  @Local serviceList: GridBanner[] = [];
  @Local commonlyUsed: GridBanner[] = [];
  @Event currentIndexChange: (value: number) => void = (value: number) => {
  };
  @Local currentLocation: string = ''
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    this.initDataSource()
  }

  aboutToDisappear(): void {
    emitter.off(EmitterEventId.GET_SERVICE)
  }

  initDataSource() {
    /*
       * 接收消息
       * 预加载存储在AppStorage中，如果有值则取AppStorage中的值，
       * 没有值则正常走接口获取
       * */
    if (AppStorage.get('homeServiceList')) {
      let homeServiceList = AppStorage.get('homeServiceList') as HomeServiceList
      this.gridBanner = homeServiceList?.allService ?? []
      this.hotServices = homeServiceList?.hotServices ?? []
      this.commonlyUsed = homeServiceList?.commonlyUsed ?? []
      this.serviceList = homeServiceList?.convenienceService ?? []
      return
    }
    let event: emitter.InnerEvent = {
      eventId: EmitterEventId.GET_SERVICE,
    };
    let callback = (eventData: emitter.EventData): void => {
      let result: HomeServiceList = eventData.data?.homeServiceList as HomeServiceList
      this.gridBanner = result?.allService ?? []
      this.commonlyUsed = result?.commonlyUsed ?? []
      this.hotServices = result?.hotServices ?? []
      this.serviceList = result?.convenienceService ?? []
      AppStorage.setOrCreate('homeServiceList', eventData.data?.homeServiceList)
    };

    emitter.on(event, callback);
  }

  build() {
    Column() {
      ServiceTitle({
        title: '首页',
        titleColor: $r('sys.color.white'),
      })
      Scroll() {
        Column() {
          InstitutionPersonalCard({
            commonlyUsed: this.commonlyUsed,
          })
          BannerGrid({
            gridBanner: this.gridBanner,
            currentIndexChange: (value: number) => {
              this.currentIndexChange(value)
            },
          })
          HotServices({
            hotServices: this.hotServices,
          })
          ConvenientService({
            serviceList: this.serviceList,
          })
        }
      }
      .layoutWeight(1)
      .height(Constants.FULL_PERCENT_WIDTH)
      .scrollBar(BarState.Off)
    }
    .linearGradient({
      angle: 180,
      colors: [
        ['#1856FF', 0.0],
        [$r('sys.color.background_secondary'), 0.4],
        [$r('sys.color.background_secondary'), 1.0],
      ],
    })
  }
}