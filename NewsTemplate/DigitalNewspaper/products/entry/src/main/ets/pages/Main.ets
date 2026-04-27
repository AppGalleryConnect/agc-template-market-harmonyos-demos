import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { AppPrivacyUtils, GridRowColSetting, LoginUtil } from 'lib_foundation';
import { Constant } from '../common/Constant';
import { ENewsViewModel } from '../viewmodels/ENewsViewModel';
import { DigitalNews } from '../pages/DigitalNewspaper';

@Builder
export function MainBuilder() {
  Main()
}

@ComponentV2
struct Main {
  @Local privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  @Local vm: ENewsViewModel = new ENewsViewModel();
  @Local breakpoint: string = '';

  async aboutToAppear(): Promise<void> {
    await this.vm.queryNewsSourceList();
    await this.vm.queryNewspaperPages();
  }

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (this.privacyImpl.agreeFlag) {
      Logger.info('Main', 'user has agree the privacy, start silent login and apply permission');
      LoginUtil.silentLogin();
    }
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Column() {
            if (this.vm.newspaperPages.length) {
              DigitalNews({
                newspaperPages: this.vm.newspaperPages,
                newsSourceList: this.vm.newsSourceList,
                selectNewsSource: this.vm.selectNewsSource,
                selectDate: this.vm.selectDate,
                themeColor: $r('app.color.theme_color'),
                onDateChange: (date) => {
                  this.vm.onDateChange(date);
                },
                onNewsSourceChange: (source) => {
                  this.vm.onNewsSourceChange(source);
                },
                onAreaClick: (area) => {
                  this.vm.jumpNewsDetail(area);
                },
              })
            }
          }
          .width(Constant.FULL_PERCENT)
          .layoutWeight(1)

          // todo 可选，若需要内容模糊，可放开下面注释代码
          // .foregroundBlurStyle(this.privacyImpl.agreeFlag ? BlurStyle.NONE : BlurStyle.Thin)
        }
      }
      .margin({
        left: GridRowColSetting.getPageMargin(this.breakpoint),
        right: GridRowColSetting.getPageMargin(this.breakpoint)
      })
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}