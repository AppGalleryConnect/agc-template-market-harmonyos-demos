import { CloudFunction, CloudFunctionInquiryResult, Constants, DrugInquiryItem, SearchHistory } from 'common'
import { PersistenceV2, promptAction } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { ModuleHeaderFilter } from './ModuleHeaderFilter'

@ComponentV2
export struct DrugInquiry {
  @Local searchValue: string = ''
  @Param title: string = ''
  @Local drugInquiryList: DrugInquiryItem[] = []
  private originDrugInquiryList: DrugInquiryItem[] = []
  @Local currentLocation: string = '北京市'
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Local historyShow: boolean = false

  dealError() {
    promptAction.showToast({ message: $r('app.string.failed_location') })
  }

  @Monitor('searchValue')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      console.log(`${path} changed from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`)
      if (monitor.value(path)?.now !== '') {
        this.drugInquiryList =
          this.drugInquiryList.filter((item: DrugInquiryItem) => item.name.includes(monitor.value(path)?.now as string))
        this.searchHistory.historyList.unshift(monitor.value(path)?.now as string)
        this.searchHistory.historyList = this.searchHistory.historyList.slice(0, 4)
        this.historyShow = false
      } else {
        this.drugInquiryList = this.originDrugInquiryList
        this.historyShow = true
      }
    })
  }

  @Builder
  drugInquiryCard(item: DrugInquiryItem) {
    Column({ space: Constants.CONTAINER_SPACE_TEN }) {
      Column() {
        Text(item.name)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
      }.width(Constants.FULL_PERCENT_WIDTH).alignItems(HorizontalAlign.Start)

      Column({ space: Constants.CONTAINER_SPACE_TEN }) {
        Row() {
          Text($r('app.string.drug_code')).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
          Text(item.code).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text($r('app.string.manufacturer')).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
          Text(item.manufacturer).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text($r('app.string.specification')).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
          Text(item.specification).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text($r('app.string.dosage_form')).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
          Text(item.dosage).fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(Constants.RADIUS_EIGHT)
      .padding($r('app.float.drug_inquiry_content_padding'))
      .width(Constants.FULL_PERCENT_WIDTH)
    }
    .backgroundColor($r('sys.color.background_primary'))
    .padding($r('app.float.drug_inquiry_padding'))
    .width(Constants.FULL_PERCENT_WIDTH)
    .borderRadius(Constants.RADIUS_SIXTY)
  }

  build() {
    NavDestination() {
      Column() {
        ModuleHeaderFilter({
          searchValue: this.searchValue,
          searchFocus: () => {
            this.historyShow = true
          },
          searchBlur: () => {
            this.historyShow = false
          },
          valueChange: (value: string) => {
            this.searchValue = value
          },
        })
        Stack({ alignContent: Alignment.TopStart }) {
          List() {
            if (this.drugInquiryList.length <= 0) {
              ListItem() {
                Column({ space: Constants.CONTAINER_SPACE_TEN }) {
                  Image($r('app.media.no_data')).width($r('app.float.empty_width')).height($r('app.float.empty_height'))
                  Text($r('app.string.no_data'))
                }
                .width(Constants.FULL_PERCENT_WIDTH)
                .height(Constants.FULL_PERCENT_HEIGHT)
                .justifyContent(FlexAlign.Center)
              }
            } else {
              ForEach(this.drugInquiryList, (item: DrugInquiryItem) => {
                ListItem() {
                  this.drugInquiryCard(item)
                }
                .margin({ top: $r('app.float.drug_inquiry_list_margin') })
              }, (item: DrugInquiryItem) => item.code)
            }
          }
          .onAppear(async () => {
            let resp = await CloudFunction.getServiceList('inquiry')
            if ((resp as CloudFunctionInquiryResult).result.ret.code === 0) {
              let result: DrugInquiryItem[] =
                (resp as CloudFunctionInquiryResult).result.result as DrugInquiryItem[]
              this.drugInquiryList = result
              this.originDrugInquiryList = JSON.parse(JSON.stringify(this.drugInquiryList))
            }
          })
          .layoutWeight(1)
          .scrollBar(BarState.Off)

          Column() {
            Column() {
              Text('历史搜索记录')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
            }

            if (this.searchHistory.historyList.length <= 0) {
              Column() {
                Text('暂无历史记录').fontSize($r('sys.float.Caption_L'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
              }.margin({ top: 23 }).width('100%').alignItems(HorizontalAlign.Center)
            } else {
              Column() {
                ForEach(this.searchHistory.historyList, (item: string) => {
                  Row() {
                    Image($r('app.media.search')).width(10).height(10).margin({ right: 13 })
                    Text(item)
                      .margin({ top: 13, bottom: 13 })
                      .fontSize($r('sys.float.Body_S'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .onClick(() => {
                        this.historyShow = false
                        this.searchValue = item
                        this.drugInquiryList =
                          this.drugInquiryList.filter((value: DrugInquiryItem) => value.name.includes(item))
                      })
                  }

                  Divider()
                })
              }.width('100%').alignItems(HorizontalAlign.Start)
            }

            Column() {
              Text('清除历史记录').fontSize($r('sys.float.Caption_L'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .margin({ top: 24 })
            .width('100%')
            .onClick(() => {
              this.searchHistory.historyList = []
            })
            .alignItems(HorizontalAlign.Center)
            .visibility(this.searchHistory.historyList.length ? Visibility.Visible : Visibility.None)
          }
          .visibility(this.historyShow ? Visibility.Visible : Visibility.None)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .backgroundColor($r('sys.color.background_primary'))
          .margin({ top: 12 })
          .padding({
            top: 16,
            left: 12,
            right: 12,
            bottom: 12,
          })
          .borderRadius(16)
        }

      }.backgroundColor($r('sys.color.background_secondary'))

    }
    .title(this.title)
    .padding({
      top: Number(AppStorage.get('topRectHeight')),
      left: 12,
      right: 12,
      bottom: 12,
    })
  }
}