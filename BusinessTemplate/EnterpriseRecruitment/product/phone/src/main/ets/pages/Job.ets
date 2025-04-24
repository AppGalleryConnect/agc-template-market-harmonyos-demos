import {
  AdaptiveButton,
  AvoidArea,
  CommonConstants,
  Divider,
  FilterButton,
  JobListItem,
  SearchType,
  TitleBar
} from '@ohos_agcit/common_component';
import { AppStorageV2, router } from '@kit.ArkUI';
import { MyDataSource } from '@ohos_agcit/common_component';
import { JSON } from '@kit.ArkTS';


let addressList: SearchType[] = CommonConstants.ADDRESS_COLLECTION;

@Entry
@ComponentV2
export struct Job {
  allList: Array<JobListItem> = CommonConstants.JOB_LIST
  buttonList: SearchType[] = CommonConstants.RECRUITMENT_COLLECTION;
  jobTypeList: SearchType[] = CommonConstants.JOB_COLLECTION;
  myDivider: Divider = new Divider(1, 0, 0, $r('app.color.divider_gray'))
  @Param @Once jobTypeSelectIndex: number = 0
  @Local recruitmentSelectIndex: number | undefined = undefined
  @Local addressSelectIndex: number | undefined = undefined
  @Local lazyListData: MyDataSource<JobListItem> = new MyDataSource();
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local address: number | undefined = undefined;
  @Local recruitmentType: number | undefined = undefined;
  @Local isHalfShow: boolean = false;
  @Local searchInput: string = ''

  aboutToAppear() {
    this.updateList(this.allList)
  }

  build() {
    Column() {
      Column() {
        TitleBar({ text: $r('app.string.job') })
          .width('100%')
          .height('75%')
      }
      .padding({ top: '2%', left: '6%', right: '6%' })
      .height('8%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // job search
      Row() {
        Row() {
          Search({ placeholder: '职位搜索' })
            .width('80%')
            .height('100%')
            .onSubmit((input: string) => {
              this.searchInput = input.toLowerCase()
              this.updateList(this.filterByCondition());
            })
            .onChange((input: string) => {
              this.searchInput = input;
              if (this.searchInput === '') {
                this.updateList(this.filterByCondition());
              }
            })
          Blank()
          Image(this.isHalfShow ? $r('app.media.filter_focus') : $r('app.media.filter_unfocus'))
            .width('15%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              this.isHalfShow = !this.isHalfShow
            })
        }
        .height('70%')
      }
      .padding({ left: '6%' })
      .height('8%')
      .width('100%')

      // job type
      Row() {
        ForEach(this.buttonList, (item: SearchType) => {
          FilterButton({
            title: item.title,
            selfIndex: item.index,
            clickIndex: this.jobTypeSelectIndex,
            invoke: (selfIndex: number) => {
              this.jobTypeSelectIndex = selfIndex
              this.updateList(this.filterByCondition());
            }
          })
        })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .height('8%')
      .width('100%')
      .padding({ left: '6%', right: '6%' })

      // job list
      List({ space: 10 }) {
        LazyForEach(this.lazyListData, (item: JobListItem) => {
          ListItem() {
            Column() {
              Text(item.jobName)
                .width('100%')
                .fontSize($r('app.float.font_size_18'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500)
                .textAlign(TextAlign.Start)
              Row() {
                Text(CommonConstants.ADDRESS_MAP.get(item.address) + ' · ' + item.jobType)
                  .fontSize($r('app.float.font_size_15'))
                Blank()
                Text(item.publishTime)
                  .fontSize($r('app.float.font_size_15'))
                  .fontWeight(CommonConstants.FONT_WEIGHT_400)
                  .fontColor($r('app.color.common_gray_light'))
              }
              .margin({ top: 5 })
              .width('100%')
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/jobRoute/JobDetail',
                params: item
              }, router.RouterMode.Standard)
            })
            .justifyContent(FlexAlign.SpaceEvenly)
            .height('12%')
          }
        }, (item: JobListItem) => JSON.stringify(item))
      }
      .width('100%')
      .height('76%')
      .padding({ left: '8%', right: '8%', top: '5%' })
      .divider(this.myDivider)
    }
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
    })
    .width('100%')
    .height('100%')
    .bindSheet($$this.isHalfShow, this.MyFilterBuilder(), {
      height: 500,
    })
  }

  private filterByCondition() {
    let filterList = this.allList.filter(item => item.recruitmentTag === this.jobTypeSelectIndex);
    if (this.recruitmentSelectIndex !== undefined) {
      filterList = filterList.filter(item => item.recruitmentType === this.recruitmentSelectIndex)
    }
    if (this.addressSelectIndex !== undefined) {
      filterList = filterList.filter(item => item.address === this.addressSelectIndex)
    }
    if (this.searchInput !== '') {
      filterList = filterList.filter(item => item.jobName.toLowerCase().includes(this.searchInput))
    }
    return filterList;
  }

  private updateList(list: Array<JobListItem>) {
    this.lazyListData.clear();

    for (let i = 0; i < list.length; i++) {
      this.lazyListData.pushData(list[i]);
    }
  }

  @Builder
  MyFilterBuilder() {
    Column() {
      Text('筛选')
        .fontSize($r('app.float.font_size_22'))
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
        .margin({ bottom: 30 })
      Text('职位类型')
        .fontSize($r('app.float.font_size_18'))
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .margin({ bottom: 20 })
      Grid() {
        ForEach(this.jobTypeList, (item: SearchType) => {
          GridItem() {
            AdaptiveButton({
              item: item,
              clickIndex: this.recruitmentSelectIndex,
              invoke: (index: number) => {
                if (this.recruitmentSelectIndex === index) {
                  this.recruitmentSelectIndex = undefined
                } else {
                  this.recruitmentSelectIndex = index
                }
              }
            })
          }
        })
      }
      .columnsGap(12)
      .rowsGap(10)
      .width('100%')

      Text('工作地点')
        .fontSize($r('app.float.font_size_18'))
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .margin({ top: 20, bottom: 20 })
      Grid() {
        ForEach(addressList, (item: SearchType) => {
          GridItem() {
            AdaptiveButton({
              item: item,
              clickIndex: this.addressSelectIndex,
              invoke: (index: number) => {
                if (this.addressSelectIndex === index) {
                  this.addressSelectIndex = undefined
                } else {
                  this.addressSelectIndex = index
                }
              }
            })
          }
        })
      }
      .columnsGap(12)
      .rowsGap(10)
      .width('100%')

      Row() {
        Button('重置')
          .fontColor($r('app.color.common_blue'))
          .backgroundColor($r('app.color.button_gray'))
          .width('45%')
          .onClick(() => {
            this.recruitmentSelectIndex = undefined
            this.addressSelectIndex = undefined
            this.updateList(this.allList)
            this.isHalfShow = false

          })

        Button('完成')
          .fontColor(Color.White)
          .backgroundColor($r('app.color.common_blue'))
          .width('45%')
          .onClick(() => {
            this.updateList(this.filterByCondition());
            this.isHalfShow = false
          })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .margin({ top: 30 })
    }
    .alignItems(HorizontalAlign.Start)
    .height('100%')
    .width('100%')
    .padding({
      left: '4%',
      right: '4%',
      top: 20,
      bottom: px2vp(this.avoidArea.bottomRectHeight)
    })
  }
}