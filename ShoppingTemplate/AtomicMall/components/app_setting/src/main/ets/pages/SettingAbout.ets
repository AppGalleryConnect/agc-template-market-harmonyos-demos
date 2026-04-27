import { CommonConstants } from '../constants/CommonConstants';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { SettingAboutVM } from '../viewmodels/SettingAboutVM';

@Builder
export function SettingAboutBuilder() {
  SettingAbout()
}

@ComponentV2
struct SettingAbout {
  vm: SettingAboutVM = new SettingAboutVM();

  build() {
    NavDestination() {
      NavHeaderBar({ title: '关于' })
      if (this.vm.configInfo.isSheet) {
        this.coreView()
      } else {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            this.coreView()
          }
        }
        .layoutWeight(1)
      }
    }
    .attributeModifier(this.vm.pageModifier)
    .backgroundColor(this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary'))
  }

  @Builder
  coreView() {
    Scroll() {
      Column() {
        this.appInfo()
        this.cardInfo()
        Blank()
        this.otherInfo()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({ bottom: CommonConstants.PADDING_M })
    }
    .attributeModifier(this.vm.scrollModifier)
  }

  @Builder
  appInfo() {
    Column({ space: CommonConstants.SPACE_S }) {
      Row()
        .layoutWeight(1)
        .constraintSize({
          minHeight: 16,
          maxHeight: 32,
        })
      Image(this.vm.appIcon)
        .width(72)
        .aspectRatio(1)
        .borderRadius($r('app.float.large_radius'))
        .draggable(false)
      Text(this.vm.appName)
        .fontSize(this.vm.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Row()
        .layoutWeight(1)
        .constraintSize({
          minHeight: 16,
          maxHeight: 32,
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  cardInfo() {
    Column() {
      Row() {
        Column({ space: CommonConstants.SPACE_XXS }) {
          Row({ space: CommonConstants.SPACE_XS }) {
            Text('版本信息')
              .fontSize(this.vm.fontModel.getFg(16))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxFontScale(2)
            Circle()
              .width(6)
              .aspectRatio(1)
              .backgroundColor($r('sys.color.warning'))
              .visibility(this.vm.hasNewVersion ? Visibility.Visible : Visibility.None)
          }

          Text(this.vm.appVersionName)
            .fontSize(this.vm.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .maxFontScale(2)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: 10,
          bottom: 10,
        })

        Row({ space: CommonConstants.SPACE_XS }) {
          if (this.vm.loading) {
            LoadingProgress()
              .width(24)
              .aspectRatio(1)
              .color($r('sys.color.icon_secondary'))
          } else {
            Text(this.vm.updateLabel)
              .fontSize(this.vm.fontModel.getFg(14))
              .fontColor($r('sys.color.font_secondary'))
              .maxFontScale(1.3)
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize($r('app.float.normal_img_size'))
              .fontColor([$r('sys.color.font_fourth')])
          }
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .onClick(() => {
        this.vm.checkUpdate();
      })

      Divider()

      Row() {
        Column({ space: CommonConstants.SPACE_XXS }) {
          Text('客服电话')
            .fontSize(this.vm.fontModel.getFg(16))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
          Text(this.vm.configInfo.aboutModel.hotline)
            .fontSize(this.vm.fontModel.getFg(14))
            .fontColor($r('sys.color.font_secondary'))
            .maxFontScale(2)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: 10,
          bottom: 10,
        })
        .onClick(() => {
          this.vm.callHotline();
        })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('app.float.xxl_radius'))
    .padding({
      top: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_L,
      left: CommonConstants.PADDING_M,
      right: CommonConstants.PADDING_M,
    })
    .margin({ top: CommonConstants.PADDING_L })
  }

  @Builder
  otherInfo() {
    Column() {
      Text(this.vm.configInfo.aboutModel.icpText)
        .fontSize(this.vm.fontModel.getFg(12))
        .fontColor(this.vm.configInfo.themeColor)
        .maxFontScale(2)
        .onClick(() => {
          this.vm.goWebsite();
        })
      Text(this.vm.configInfo.aboutModel.copyrightText)
        .fontSize(this.vm.fontModel.getFg(12))
        .fontColor($r('sys.color.font_secondary'))
        .maxFontScale(2)
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}