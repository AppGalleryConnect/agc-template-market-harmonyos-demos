import { AlertDialog, AppStorageV2, LengthMetrics } from '@kit.ArkUI'
import { appRouter } from '@agctemplate/utils'
import { TopBar } from '../component/TopBar'
import {
  AppStorageKeys,
  BreakPoint,
  BreakPointType,
  BreakPointValue,
  FontModel,
  fp2pxUtil,
  MinePageVM,
  StatusBarHeight
} from '@agctemplate/widgets';
import { getMedia } from '@agctemplate/resources';

@Preview
@ComponentV2
export struct MyPreferencesPage {
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local channels: CardItem[] = [new CardItem('女生短剧'), new CardItem('男生短剧')]
  private categoryName: string[] =
    ['古代', '家庭', '年代', '穿越', '职场', '重生', '权谋', '都市', '男频', '女频', '仙侠', '萌宝', '游戏', '悬疑',
      '武侠', '校园', '历史', '军事']
  @Local category: CardItem[] = this.categoryName.map(item => new CardItem(item))
  @Local vm: MinePageVM = MinePageVM.instance
  @Local btnState: boolean = false
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '是否清除偏好?',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确定',
        fontColor: $r('sys.color.ohos_id_color_warning'),
        action: () => {
          this.channels.forEach(channel => channel.isSelect = false)
          this.category.forEach(category => category.isSelect = false)
          this.vm.userInfo.channels =
            new Set(this.channels.filter(channel => channel.isSelect).map(channel => channel.name))
          this.vm.userInfo.category =
            new Set(this.category.filter(category => category.isSelect).map(category => category.name))
        },
      },
    }),
  })

  aboutToAppear(): void {
    this.channels.forEach(channel => {
      channel.isSelect = this.vm.userInfo.channels.has(channel.name)
    })
    this.category.forEach(category => {
      category.isSelect = this.vm.userInfo.category.has(category.name)
    })
    this.updateBtnState()
  }

  updateBtnState() {
    const selectedChannels = new Set(this.channels.filter(channel => channel.isSelect).map(channel => channel.name))
    const selectedCategories =
      new Set(this.category.filter(category => category.isSelect).map(category => category.name))
    const originalChannels = this.vm.userInfo.channels
    const originalCategories = this.vm.userInfo.category
    const channelsChanged = !this.isEqualSets(selectedChannels, originalChannels)
    const categoriesChanged = !this.isEqualSets(selectedCategories, originalCategories)
    this.btnState = channelsChanged || categoriesChanged
  }

  isEqualSets(a: Set<string>, b: Set<string>): boolean {
    if (a.size !== b.size) {
      return false
    }
    for (const item of a) {
      if (!b.has(item)) {
        return false
      }
    }
    return true
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部
        this.topBuilder()
        Column() {
          Text('频道')
            .fontSize(this.fontModel.getFg(16))
            .fontWeight(500)
            .lineHeight(this.fontModel.getDesFg(21))
            .fontColor($r('sys.color.font_primary'))
            .height(56)

          Row() {
            ForEach(this.channels, (item: CardItem, index: number) => {
              Row() {
                Text(item.name)
                  .fontSize(this.fontModel.getFg(16))
                  .fontWeight(500)
                  .lineHeight(this.fontModel.getDesFg(21))
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ left: 12 })

                Image(index === 0 ? getMedia('app.media.girl_short_drama') : getMedia('app.media.boy_short_drama'))
                  .width(48)
                  .borderRadius(24)
                  .aspectRatio(1)
                  .backgroundColor(item.isSelect ? $r('sys.color.icon_on_secondary') :
                    $r('sys.color.icon_on_secondary'))
                  .offset({ x: 8, y: 16 })
              }
              .onClick(() => {
                item.isSelect = !item.isSelect
                this.updateBtnState()
              })
              .clip(true)
              .justifyContent(FlexAlign.SpaceBetween)
              .width('48%')
              .height(64)
              .borderRadius(16)
              .backgroundColor(item.isSelect ? 'rgba(236, 110, 69, 0.2)' : $r('sys.color.comp_background_tertiary'))
            }, (item: CardItem, index: number) => item.name + index)
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')

          Text() {
            Span('分类')
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(500)
              .lineHeight(this.fontModel.getDesFg(21))
              .fontColor($r('sys.color.font_primary'))
            Span(`（已选择${this.category.filter(item => item.isSelect).length}项）`)
              .fontSize(this.fontModel.getFg(14))
              .fontWeight(400)
              .lineHeight(this.fontModel.getDesFg(19))
              .fontColor($r('sys.color.font_secondary'))
          }
          .height(56)

          Flex({
            wrap: FlexWrap.Wrap,
            justifyContent: FlexAlign.Start,
            space: {
              main: new BreakPointType<LengthMetrics>({
                sm: LengthMetrics.vp(8),
                md: LengthMetrics.vp(10),
                lg: LengthMetrics.vp(16)
              }).getValue(this.currentBreakpoint.value)
            }
          }) {
            ForEach(this.category, (item: CardItem, index: number) => {
              Column() {
                Text(item.name)
                  .textAlign(TextAlign.Center)
                  .fontSize(this.fontModel.getFg(14))
                  .fontWeight(500)
                  .lineHeight(this.fontModel.getDesFg(19))
                  .fontColor($r('sys.color.font_primary'))
                  .onClick(() => {
                    item.isSelect = !item.isSelect
                    this.updateBtnState()
                  })
                  .width(new BreakPointType<number>({
                    sm: 76,
                    md: 76,
                    lg: 86
                  }).getValue(this.currentBreakpoint.value))
                  .height(28)
                  .borderRadius(14)
                  .backgroundColor(item.isSelect ? 'rgba(236, 110, 69, 0.2)' : $r('sys.color.comp_background_tertiary'))
              }
              .margin({ bottom: 8 })
            }, (item: CardItem, index: number) => item.name + index)
          }

          Blank()
          Column() {
            Button('保存')
              .borderRadius(20)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor('#EE5D1A')
              .fontSize(fp2pxUtil(16))
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .constraintSize({
                maxWidth: 448
              })
              .height(40)
              .enabled(this.btnState)
              .onClick(() => {
                this.vm.userInfo.channels =
                  new Set(this.channels.filter(channel => channel.isSelect).map(channel => channel.name))
                this.vm.userInfo.category =
                  new Set(this.category.filter(category => category.isSelect).map(category => category.name))
                this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
                this.updateBtnState()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .constraintSize({
          maxWidth: 805
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`, bottom: 36 })
  }

  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          appRouter.back()
        },
        title: '我的偏好'
      })
      Row() {
        Button('清空')
          .fontSize(fp2pxUtil(16))
          .margin({ left: 8 })
          .height(40)
          .borderRadius(20)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .onClick(() => {
        this.deleteDialogController.open()
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(56)
    .width('100%')
  }
}

@ObservedV2
export class CardItem {
  @Trace name: string
  @Trace isSelect: boolean

  constructor(name: string, isSelect: boolean = false) {
    this.name = name;
    this.isSelect = isSelect;
  }
}

@Builder
export function MyPreferencesPageBuilder() {
  MyPreferencesPage();
}