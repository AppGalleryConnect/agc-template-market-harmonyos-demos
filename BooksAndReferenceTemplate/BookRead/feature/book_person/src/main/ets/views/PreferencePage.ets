import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  GenderOption,
  PreferenceInfo,
  ReturnButton,
  TCRouter
} from 'common';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';

@ObservedV2
class GenderSelectItem {
  genderOption: GenderOption = GenderOption.UNSELECTED
  @Trace selected: boolean;
  text: string;

  constructor(content: string, gender: GenderOption) {
    this.text = content;
    this.genderOption = gender
    this.selected = false;
  }
}

@ObservedV2
class NovelTypeItem {
  type: string;
  @Trace selected: boolean;

  constructor(content: string) {
    this.type = content;
    this.selected = false;
  }
}

@ComponentV2
export struct PreferencePage {
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local preferenceInfo: PreferenceInfo =
    AppStorageV2.connect(PreferenceInfo, 'preferenceInfo', () => new PreferenceInfo())!
  @Local isGenderSelected: boolean = this.preferenceInfo.genderOption !== GenderOption.UNSELECTED;
  @Local selectedTypeNum: number = this.preferenceInfo.novelType.length;
  @Local genderSelectList: GenderSelectItem[] = [new GenderSelectItem('男频', GenderOption.MALE),
    new GenderSelectItem('女频', GenderOption.FEMALE),
    new GenderSelectItem('都喜欢', GenderOption.BOTH),];
  @Local selectedTypeList: NovelTypeItem[] = [new NovelTypeItem('都市'),
    new NovelTypeItem('玄幻'),
    new NovelTypeItem('历史'),
    new NovelTypeItem('仙侠'),
    new NovelTypeItem('惊悚恐怖'),
    new NovelTypeItem('科幻'),
    new NovelTypeItem('游戏'),
    new NovelTypeItem('推理悬疑'),
    new NovelTypeItem('同人作品'),
    new NovelTypeItem('校园'),
    new NovelTypeItem('奇幻'),
    new NovelTypeItem('军事'),
    new NovelTypeItem('武侠'),
    new NovelTypeItem('轻小说'),
    new NovelTypeItem('竞技')];

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.preferenceHeadBarView()
          Column({ space: 12 }) {
            Row() {
              Text('请选择想看的频道：')
                .height(27)
                .fontWeight(500)
                .fontSize(20)
                .align(Alignment.Start)
            }
            .width(Constants.FULL_SIZE)
            .justifyContent(FlexAlign.Start)

            Row({ space: 12 }) {
              this.genderOptionView(this.genderSelectList[0], $r('app.media.novel_for_men'))
              this.genderOptionView(this.genderSelectList[1], $r('app.media.novel_for_women'))
              this.genderOptionView(this.genderSelectList[2], $r('app.media.novel_for_both'))
            }
            .height('auto')
            .width(Constants.FULL_SIZE)
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('请选择想看的频道：')
                .height(27)
                .fontWeight(500)
                .fontSize(20)
                .textAlign(TextAlign.Start)
              Text('(已选择' + this.selectedTypeNum + '）')
                .width(104)
                .height(16)
                .fontWeight(400)
                .fontSize(12)
                .textAlign(TextAlign.Start)
            }
            .width(Constants.FULL_SIZE)
            .justifyContent(FlexAlign.Start)

            this.selectTypeView()
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)
          .padding({
            left: 16,
            right: 16,
            top: 13.5
          })
        }

        Button('保存')
          .width(312)
          .height(40)
          .borderRadius(20)
          .padding({
            top: 9,
            right: 16,
            bottom: 9,
            left: 16
          })
          .backgroundColor('#E84026')
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .enabled(this.isGenderSelected === false && this.selectedTypeNum === 0 ? false : true)
          .align(Alignment.Bottom)
          .onClick(() => {
            if (!(this.isGenderSelected === false && this.selectedTypeNum === 0)) {
              this.savePreferenceInfo()
            }
          })
          .margin({ bottom: 52 })
      }
      .height(Constants.FULL_SIZE)
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
    .onWillAppear(() => {
      this.showPreference()
    })
  }

  @Builder
  preferenceHeadBarView() {
    Column() {
      Row() {
        Row() {
          ReturnButton()
          Text('阅读偏好设置')
            .fontWeight(500)
            .fontSize(20)
            .height(27)
            .textAlign(TextAlign.Start)
            .margin({ left: 8 })
        }

        Row() {
          Text('清空')
            .fontSize(14)
            .height(19)
            .textAlign(TextAlign.Center)
            .fontColor(this.isGenderSelected === false && this.selectedTypeNum === 0 ? $r('sys.color.font_tertiary') :
              $r('sys.color.font_primary'))
        }
        .padding({
          top: 8,
          bottom: 8
        })
        .onClick(() => {
          this.isGenderSelected = false
          this.genderSelectList.forEach(item => item.selected = false);
          this.selectedTypeList.forEach(item => item.selected = false);
          this.selectedTypeNum = 0
        })
      }
      .width(360)
      .height(56)
      .padding({ left: 16, right: 16 })
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(0)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: this.windowTopHeight
    })
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  genderOptionView(genderSelectItem: GenderSelectItem, image: ResourceStr) {
    RelativeContainer() {
      Image(image)
        .width('100%')
        .borderRadius(14)
        .border({
          width: genderSelectItem.selected ? 2 : 0,
          color: '#E84026'
        })
        .id('image')

      Text(genderSelectItem.text)
        .width(24)
        .height(54)
        .fontSize(20)
        .fontWeight(700)
        .fontColor('#FFFFFF') // 白色
        .margin({ top: 5, right: 5 })
        .alignRules({
          top: { anchor: 'image', align: VerticalAlign.Top },
          right: { anchor: 'image', align: HorizontalAlign.End }
        })

      Checkbox({ name: genderSelectItem.text, group: 'checkboxGroup', })
        .select(genderSelectItem.selected)
        .height(24)
        .width(24)
        .padding({
          top: 2,
          bottom: 2,
          left: 2,
          right: 2
        })
        .selectedColor('#E84026')
        .shape(CheckBoxShape.CIRCLE)
        .onClick(() => {
          if (this.isGenderSelected) {
            this.genderSelectList.forEach(item => item.selected = false);
            genderSelectItem.selected = true
          } else {
            this.isGenderSelected = true
            genderSelectItem.selected = true
          }
        })
        .alignRules({
          bottom: { anchor: 'image', align: VerticalAlign.Bottom },
          right: { anchor: 'image', align: HorizontalAlign.End }
        })
    }
    .layoutWeight(1)
    .height('auto')
    .width('auto')
    .onClick(() => {
      if (this.isGenderSelected) {
        this.genderSelectList.forEach(item => item.selected = false);
        genderSelectItem.selected = true
      } else {
        this.isGenderSelected = true
        genderSelectItem.selected = true
      }
    })
  }

  @Builder
  selectTypeView() {
    Flex({ wrap: FlexWrap.Wrap, space: { main: new LengthMetrics(8), cross: new LengthMetrics(8) } }) {
      ForEach(this.selectedTypeList, (item: NovelTypeItem, index: number) => {
        ListItem() {
          Row() {
            Text(item.type)
              .fontSize(fp2pxUtil(12))
              .fontWeight('medium')
              .fontColor(item.selected ? $r('app.color.pure_white') : $r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            item.selected = !item.selected
            this.selectedTypeNum += item.selected ? 1 : -1;
          })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8
          })
          .width(76)
          .height(28)
          .borderRadius(14)
          .backgroundColor(item.selected ? '#E84026' : $r('sys.color.comp_background_tertiary'))
        }
      }, (item: NovelTypeItem) => `${item.type}+${new Date().toString()}`)
    }
  }

  showPreference() {
    if (this.isGenderSelected) {
      this.genderSelectList.forEach(item => {
        if (item.genderOption === this.preferenceInfo.genderOption) {
          item.selected = true
        }
      })
    }
    if (this.preferenceInfo.novelType) {
      this.selectedTypeList.forEach(item => {
        item.selected = this.preferenceInfo.novelType.includes(item.type);
      });
    }
  }

  savePreferenceInfo() {
    let selectedGenderItems = this.genderSelectList.filter((item) => item.selected)
    let selectedTypeItems = this.selectedTypeList.filter((item) => item.selected)
    this.preferenceInfo.novelType = selectedTypeItems.map(item => item.type)
    this.preferenceInfo.genderOption =
      this.isGenderSelected ? selectedGenderItems[0].genderOption : GenderOption.UNSELECTED
    TCRouter.pop()
  }
}

