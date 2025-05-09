import { getDataFromJSON } from 'h5';
import {  Permissions } from '@kit.AbilityKit';
import { CityJson, ProvincesJson } from 'common';


@Component
export struct SiteList {
  @State pcData: Array<ProvincesJson> = [];
  @Consume('pageInfos') pageInfos: NavPathStack
  @State curCity: ResourceStr = $r('app.string.repositioning');
  @State obtainSiteSuccess: boolean = false;
  @StorageLink('selectedCity') selectedCity: string = '东城市';
  permissions: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
  ERROR_INFO: ResourceStr = $r('app.string.get_site_failed');

  initDataSource() {
    this.pcData = getDataFromJSON<ProvincesJson>('SiteListPage-ProvinceDate.json', this);
  }

  onPageShow() {
    this.onInit();
  }

  aboutToAppear() {
    this.initDataSource();
    this.onInit();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.office_page_pic11'))
            .width(30)
            .height(30)
            .objectFit(ImageFit.Cover)
            .onClick(() => this.pageInfos.pop())
          Text($r('app.string.site_list'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Center)
            .fontSize($r('app.integer.text_font_big'))
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding({ right: 15 })
        .margin({ bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text($r('app.string.current_site'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Center)
            .fontSize($r('sys.float.Body_M'))

          Text(this.selectedCity)
            .fontColor(Color.Black)
            .textAlign(TextAlign.Center)
            .fontSize($r('sys.float.Body_M'))
            .margin({ left: 10, right: 10 })
            .border({ width: 1 })
            .borderColor('#ffe2e1e1')
        }.width('100%')
        .padding({ left: 12, right: 12, bottom: 16 })
        .justifyContent(FlexAlign.Start)

        Scroll() {
          Column() {
            ForEach(this.pcData, (provincesJson: ProvincesJson) => {
              Column() {
                Text(`${provincesJson.name}`)
                  .borderWidth({ bottom: 2 })
                  .borderColor({ bottom: '#007DFF' })
                  .fontColor(Color.Black)
                  .padding({ top: 15, bottom: 15 })
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Bold)
                ForEach(provincesJson.children, (cityJson: CityJson) => {
                  Row() {
                    Text(`${cityJson.name}`)
                      .fontColor(Color.Black)
                      .fontSize($r('app.integer.text_font_small'))
                  }
                  .width('100%')
                  .borderWidth({ bottom: 1 })
                  .borderColor({ bottom: $r('sys.color.font_secondary') })
                  .padding({ top: 10, bottom: 10 })
                  .justifyContent(FlexAlign.SpaceBetween)
                  .onClick(() => this.selectedPC(cityJson.name))
                }, (cityJson: CityJson) => JSON.stringify(cityJson))
              }
              .alignItems(HorizontalAlign.Start)
            }, (provincesJson: ProvincesJson) => JSON.stringify(provincesJson))
          }
          .width('100%')
          .constraintSize({ minHeight: '100%' })
          .padding({ left: 12, right: 12 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('85%')
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarWidth(0)
        .edgeEffect(EdgeEffect.None)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }

  /**
   * 更新状态
   *
   * @param city
   */
  selectedPC(cityName: string): void {
    if (this.selectedCity !== this.ERROR_INFO && this.selectedCity !== '重新定位') {
      this.selectedCity = cityName;
      this.pageInfos.pop();
    }
  }

  onInit() {
    // 在页面初始化时获取定位信息
    console.log('TAG onInit')
  }
}

