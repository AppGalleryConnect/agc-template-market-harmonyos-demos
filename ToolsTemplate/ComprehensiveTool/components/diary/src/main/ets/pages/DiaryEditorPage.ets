import { KeyboardAvoidMode, LengthUnit } from '@kit.ArkUI';
import { TITLE_MAP } from '../commons/Constant';
import { PageMode } from '../commons/Enum';
import { BaseDiaryMeta } from '../components/BaseDiaryMeta';
import { MoreMenuView } from '../components/MoreMenuView';
import { RichEditorView } from '../components/RichEditorView';
import { TextSelectView } from '../components/TextSelectView';
import { DiaryEditorPageVM } from '../viewmodel/DiaryEditorPageVM';

@Builder
export function DiaryEditorPageBuilder() {
  DiaryEditorPage()
}

@ComponentV2
export struct DiaryEditorPage {
  vm: DiaryEditorPageVM = new DiaryEditorPageVM(this.getUIContext());

  @Computed
  get title() {
    return TITLE_MAP[this.vm.pageMode]
  }

  @Computed
  get diaryCreateTime() {
    return new Date(Number(this.vm.currentDiary.updateTime))
  }

  @Computed
  get canUndo() {
    return this.vm.editorController.htmlModel.undoStack.length > 0;
  }

  @Computed
  get canRedo() {
    return this.vm.editorController.htmlModel.redoStack.length > 0;
  }

  @Computed
  get canSave() {
    return this.vm.editorController.richTextContent.length > 0;
  }

  aboutToAppear(): void {
    // 启用压缩模式避让软键盘
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET);
  }

  aboutToDisappear(): void {
    // 还原默认上抬模式
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);

    this.vm.handleDisappear()
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        if (this.vm.pageMode === PageMode.VIEW) {
          this.detailView()
        } else {
          this.pickerView()
        }

        RichEditorView({
          pageMode: this.vm.pageMode,
          editorController: this.vm.editorController,
          snapShotWebController: this.vm.snapShotWebController
        })
      }
      .height('100%')
      .width('100%')
    }
    .menus(this.vm.pageMode === PageMode.VIEW ? this.moreActionView() : this.toolBar())
    .title(this.title)
    .onReady((cxt: NavDestinationContext) => {
      this.vm.pathStack = cxt.pathStack;
      let params = cxt.pathInfo.param as Record<string, Object>;
      this.vm.initData(params)
    })
    .onBackPressed(() => {
      // 详情页面直接返回、保存直接返回
      if (this.vm.pageMode === PageMode.VIEW) {
        this.vm.stopAutoSave()
        return false;
      }
      if (this.vm.editorController.isSave) {
        this.vm.stopAutoSave();
        this.vm.pathStack.pop(this.vm.pageMode);
        return true
      }
      this.vm.onBack();
      return true
    });
  }

  @Builder
  detailView() {
    Column({ space: 16 }) {
      BaseDiaryMeta({
        date: this.diaryCreateTime,
        isPrivacy: this.vm.currentDiary.isPrivacy
      })

      Row({ space: 8 }) {
        TextSelectView({
          value: this.vm.currentDiary.weatherText,
          icon: this.vm.currentDiary.weatherIcon,
          type: 'weather',
          showFlag: true,
          paddingLeft: 8,
          paddingTop: 4
        })

        TextSelectView({
          value: this.vm.currentDiary.moodText,
          icon: this.vm.currentDiary.moodIcon,
          type: 'mood',
          showFlag: true,
          paddingLeft: 8,
          paddingTop: 4
        })
      }

      Row().width('100%').height(0.5).backgroundColor($r('sys.color.comp_divider'))
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  pickerView() {
    Flex({
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center,
      space: {
        main: {value: 8, unit: LengthUnit.VP},
        cross: {value: 8, unit: LengthUnit.VP},
      },
    }) {
      // 日期选择
      this.datePickerView()
      // 时间选择
      this.timePickerView()
      // 天气选择
      TextSelectView({
        value: this.vm.weatherText,
        icon: this.vm.weatherIcon,
        type: 'weather',
        clickAction: () => {
          this.vm.openTextPickerSheet('weather')
        }
      })
      // 心情选择
      TextSelectView({
        value: this.vm.moodText,
        icon: this.vm.moodIcon,
        type: 'mood',
        clickAction: () => {
          this.vm.openTextPickerSheet('mood')
        }
      })
    }
    .width('100%')
    .padding({ top: 8, left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
  }

  @Builder
  datePickerView() {
    Row() {
      Text(this.vm.dateLabel)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium);
      Image($r('app.media.ic_arrow_bottom'))
        .width(24)
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .padding({
      left: 16,
      right: 8,
      top: 8,
      bottom: 8,
    })
    .borderRadius(50)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.vm.handleDatePicker()
    })
  }

  @Builder
  timePickerView() {
    Row() {
      Text(this.vm.dateTime)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium);
      Image($r('app.media.ic_arrow_bottom'))
        .width(24)
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .padding({
      left: 16,
      right: 8,
      top: 8,
      bottom: 8,
    })
    .borderRadius(50)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.vm.handleTimePicker();
    })
  }

  @Builder
  toolBar() {
    Row({ space: 12 }) {
      ToolBarItemView({
        symbol: 'sys.symbol.undo',
        enable: this.canUndo,
        onClickAction: () => {
          this.vm.editorController.undo();
        }
      })

      ToolBarItemView({
        symbol: 'sys.symbol.redo',
        enable: this.canRedo,
        onClickAction: () => {
          this.vm.editorController.redo();
        }
      })

      ToolBarItemView({
        symbol: 'sys.symbol.checkmark',
        enable: this.canSave,
        onClickAction: () => {
          this.vm.save();
        }
      })
    }
    .height('100%')
    .width(150)
    .justifyContent(FlexAlign.Center)
    .margin({ right: 16 })
  }

  @Builder
  moreActionView() {
    Row(){
      Button() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontColor([$r('sys.color.font_primary')])
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .bindMenu(this.moreFunctionMenu)
    }
    .height('100%')
    .width(150)
    .justifyContent(FlexAlign.End)
    .margin({ right: 16 });
  }

  @Builder
  moreFunctionMenu() {
    MoreMenuView({
      list: this.vm.moreMenuList
    })
  }
}


@ComponentV2
struct ToolBarItemView {
  @Param symbol: string = '';
  @Param enable: boolean = true;
  @Event onClickAction: () => void;

  build() {
    Row() {
      Button() {
        SymbolGlyph($r(this.symbol))
          .fontColor(this.enable ? [$r('sys.color.font_primary')] : ['#9c9c9a'])
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .enabled(this.enable)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onClickAction?.()
      });
    }
    .width(40)
    .height(40)
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }
}