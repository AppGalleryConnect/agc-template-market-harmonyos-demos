import {
  CloudFunction,
  CloudFunctionInstitutionsResult,
  CloudFunctionServiceResult,
  Constants,
  InstitutionsItem,
  LazyDataSource,
} from 'common';
import { InstitutionsCard } from './InstitutionsCard';
import { ModuleHeaderFilter } from './ModuleHeaderFilter';


@ComponentV2
export struct InstitutionsPage {
  @Require @Param title: string;
  @Local levelSelectNumber: number = 0
  @Local levelSelectedList: string[] = ['全部', '一级', '二级']
  @Local institutionsList: LazyDataSource<InstitutionsItem> = new LazyDataSource<InstitutionsItem>()
  @Local sheetSelectList: string[] = []
  @Param isHospital: boolean = false

  async initDataSource() {
    let resp = await CloudFunction.getServiceList('institutions')
    if ((resp as CloudFunctionServiceResult).result.ret.code === 0) {
      let result: InstitutionsItem[] =
        (resp as CloudFunctionInstitutionsResult).result.result as InstitutionsItem[]
      result.forEach((item: InstitutionsItem) => this.institutionsList.pushData(item))
    }
  }

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      ModuleHeaderFilter({
        searchOnChange: (value: string) => {
          this.institutionsList.searchData(value)
        },
        initDataSource: () => {
          this.initDataSource()
        },
      })
      List() {
        LazyForEach(this.institutionsList, (item: InstitutionsItem) => {
          ListItem() {
            InstitutionsCard({
              institutionsItem: item,
              isHospital: this.isHospital,
            })
          }
          .margin({
            top: $r('app.float.institutions_list_bottom'),
            left: $r('app.float.common_margin_sixty'),
            right: $r('app.float.common_margin_sixty'),
          })
          .borderRadius(Constants.RADIUS_SIXTY)
          .backgroundColor($r('sys.color.background_primary'))
        }, (item: InstitutionsItem) => item.siteId)
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title(this.title)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}