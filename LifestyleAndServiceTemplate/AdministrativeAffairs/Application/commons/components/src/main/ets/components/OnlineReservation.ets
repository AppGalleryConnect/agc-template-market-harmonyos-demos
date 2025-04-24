import {
  CloudFunction,
  CloudFunctionInstitutionsResult,
  CloudFunctionServiceResult,
  commonToast,
  Constants,
  getCurrentLocation,
  InstitutionsItem,
  LazyDataSource,
  PermissionRequestUtils,
  ReservationRecord,
} from 'common';
import { common } from '@kit.AbilityKit';
import { InstitutionsCard } from './InstitutionsCard';
import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI';


@ComponentV2
export struct OnlineReservation {
  @Require @Param title: string;
  @Local searchValue: string = ''
  @Local currentLocation: string = '北京市'
  @Local levelSelectNumber: number = 0
  @Local levelSelectedList: string[] = ['全部', '一级', '二级']
  @Local institutionsList: LazyDataSource<InstitutionsItem> = new LazyDataSource<InstitutionsItem>()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private classifiedsList: string[] = ['医保码', '移动支付', '电子处方', '电子票据', '医保钱包']
  @Local sheetSelectList: string[] = []
  @Local edge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Param recordList: ReservationRecord[] = []

  async initDataSource() {
    let resp = await CloudFunction.getServiceList('institutions')
    if ((resp as CloudFunctionServiceResult).result.ret.code === 0) {
      let result: InstitutionsItem[] =
        (resp as CloudFunctionInstitutionsResult).result.result as InstitutionsItem[]
      result.forEach((item: InstitutionsItem) => this.institutionsList.pushData(item))
    }
  }

  aboutToAppear(): void {
    new PermissionRequestUtils(this.context).locationPermissionRequest().then(async (res) => {
      if (res === 'success') {
        getCurrentLocation().then((res: string) => {
          this.currentLocation = res
          this.initDataSource()
        })
      } else {
        this.dealError()
      }
    }).catch(() => {
      this.dealError()
    })
  }

  dealError() {
    promptAction.showToast({ message: $r('app.string.failed_location') })
  }

  @Builder
  moduleHeader() {
    Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Row() {
        Text(this.currentLocation).fontSize(Constants.FONT_SIZE_SMALL)
        Image($r('app.media.pull_down')).size({ width: $r('app.float.pull_down_width') })
      }

      Row() {
        Search({ value: this.searchValue, placeholder: $r('app.string.search_key') })
          .onChange((value: string) => {
            this.searchValue = value

          })
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')),
          })
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({
            size: $r('sys.float.Body_L'),
          })
      }.width(Constants.SIXTY_PERCENT_WIDTH)

      Row() {
        Text($r('app.string.search')).fontColor($r('app.color.search_color')).fontSize(Constants.FONT_SIZE_SMALL)
      }.onClick(() => {
        this.institutionsList.searchData(this.searchValue)
      })
    }
    .padding({
      left: $r('app.float.institutions_search_margin_lf'),
      right: $r('app.float.institutions_search_margin_lf'),
    })
    .margin({
      top: $r('app.float.institutions_search_padding_lf'),
      bottom: $r('app.float.institutions_search_padding_bt'),
    })
  }

  @Builder
  reservationRecord() {
    Column() {
      Image($r('app.media.reservation_record'))
        .width($r('app.float.medical_record_icon_size'))
        .height($r('app.float.medical_record_icon_size'))
        .fillColor(Color.White)
    }
    .width($r('app.float.medical_record_size'))
    .height($r('app.float.medical_record_size'))
    .borderRadius(Constants.HALF_PERCENT_WIDTH)
    .backgroundColor($r('app.color.institutions_appointment_fillColor'))
    .justifyContent(FlexAlign.Center)
    .position(this.edge)
    .onClick(() => {
      /*
       * 跳转到预约记录中
       * */
      this.pageInfos.pushPathByName('record', null)
    })
  }

  @Builder
  headerFilter() {
    Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Row() {
        Text(this.levelSelectNumber ? this.levelSelectedList[this.levelSelectNumber] : $r('app.string.hospital_grade'))
          .fontSize(Constants.FONT_SIZE_SMALL)
        Image($r('app.media.pull_down')).size({ width: $r('app.float.pull_down_width') })
      }
      .onClick(() => {
        commonToast.show({
          type: 'pickerDialog',
          dataList: this.levelSelectedList,
          selectedIndex: this.levelSelectNumber,
          confirmAction: (selected) => {
            this.levelSelectNumber = selected as number
            this.filterInstitutions(selected as number)
            commonToast.hide()
          },
        })
      })

      Row() {
        Text($r('app.string.more_filter')).fontSize(Constants.FONT_SIZE_SMALL)
        Image($r('app.media.pull_down')).size({ width: $r('app.float.pull_down_width') })
      }
      .onClick(() => {
        commonToast.show({
          type: 'sheetDialog',
          dataList: this.classifiedsList,
          sheetSelectList: this.sheetSelectList,
          confirmAction: (selected) => {
            // 调用筛选接口
            this.sheetSelectList = selected as string[]
            this.filterInstitutions(selected as string[])
            commonToast.hide()
          },
        })
      })
    }
    .padding({ bottom: $r('app.float.institutions_sheet_bottom') })
  }

  filterInstitutions(selected: number | string []) {
    if (typeof selected === 'number') {
      this.institutionsList.filterData(selected)
    } else {
      this.institutionsList.filterClassifieds(selected)
    }
  }

  build() {
    NavDestination() {
      this.moduleHeader()
      this.headerFilter()
      List() {
        LazyForEach(this.institutionsList, (item: InstitutionsItem) => {
          ListItem() {
            InstitutionsCard({
              institutionsItem: item,
              isReservation: true,
            })
          }
          .margin({ top: 10 })
        }, (item: InstitutionsItem) => item.siteId)
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))

      this.reservationRecord()
    }
    .title(this.title)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}