import { CARD_TYPE_OPTIONS, TouristInfo } from 'module_base';
import { GridRowColSetting } from '../constant/GridRowColSetting';
import { TouristVM } from '../viewmodel/TouristVM';
import { CardTypeSelectDialog } from './CardTypeSelectDialog';
import { DeleteConfirmDialog } from './ComfirmDialogComponent';

@Extend(Text)
function touristKeyText() {
  .fontSize($r('sys.float.Subtitle_M'))
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .width(64)
  .textAlign(TextAlign.Start);
}

@Extend(TextInput)
function touristTextInput() {
  .placeholderFont({ size: $r('sys.float.Body_L') })
  .placeholderColor($r('sys.color.font_secondary'))
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'))
  .showUnderline(true)
  .underlineColor({
    normal: '#00000000',
    typing: '#00000000',
    error: '#00000000',
    disable: '#00000000',
  })
  .borderWidth(0)
  .padding({ top: 0, bottom: 0, left: 12 })
  .layoutWeight(1);
}

@ComponentV2
export struct Tourist {
  vm: TouristVM = TouristVM.instance;
  @Local cloneTouristInfo: TouristInfo = new TouristInfo();
  @Param @Once isEdit: boolean = false;
  @Param @Once showBack: boolean = false;
  @Param @Once touristInfo: TouristInfo = new TouristInfo();
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Event close: () => void;
  // 保存联系人
  @Event addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => void;
  @Event deleteTourist: (id: string) => void;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CardTypeSelectDialog({
      change: (cardType: number) => {
        this.cloneTouristInfo.cardType = cardType;
      }, cardType: this.cloneTouristInfo.cardType,
    }), customStyle: true, autoCancel: true,
  });
  delDialogController: CustomDialogController | null = new CustomDialogController({
    builder: DeleteConfirmDialog({
      delete: () => {
        this.deleteTourist(this.touristInfo.id);
        this.goBack();
      }, type: 0,
    }), customStyle: true, autoCancel: true,
  });

  @Computed
  get getContentType() {
    const titleToContentTypeMap: Record<string, ContentType> = {
      '身份证': ContentType.ID_CARD_NUMBER, '护照': ContentType.PASSPORT_NUMBER,
    };
    return titleToContentTypeMap[this.cloneTouristInfo.cardType] ?? undefined;
  }

  aboutToAppear(): void {
    this.initData();
  }

  aboutToDisappear(): void {
    this.dialogController = null;
  }

  private initData(): void {
    this.cloneTouristInfo.id = this.touristInfo.id;
    this.cloneTouristInfo.name = this.touristInfo.name;
    this.cloneTouristInfo.phone = this.touristInfo.phone;
    this.cloneTouristInfo.cardType = this.touristInfo.cardType;
    this.cloneTouristInfo.cardNo = this.touristInfo.cardNo;
  }

  goBack() {
    if (this.showBack) {
      this.pathStack.pop();
    } else {
      this.close();
    }
  }

  build() {
    NavDestination() {
      GridRow({ columns: 12 }) {
        GridCol({ span: 12 }) {
          Column() {
            Row() {
              Row({ space: 8 }) {
                if (this.showBack) {
                  SymbolGlyph($r('sys.symbol.chevron_backward'))
                    .width(40)
                    .height(40)
                    .fontSize(24)
                    .fontColor([$r('sys.color.icon_primary')])
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                    .borderRadius(1000)
                    .padding(8)
                    .onClick(() => {
                      this.goBack();
                    });
                }
                Text(this.isEdit ? '编辑常用游客' : '添加常用游客')
                  .fontSize($r('sys.float.Title_S'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Bold);
              };

              SymbolGlyph($r('sys.symbol.xmark'))
                .width(40)
                .height(40)
                .fontSize(18)
                .fontColor([$r('sys.color.icon_primary')])
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius(1000)
                .padding(11)
                .onClick(() => {
                  this.goBack();
                });
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 16, bottom: 8 });

            Column({ space: 12 }) {
              Column({ space: 12 }) {
                Row() {
                  Text('姓名').touristKeyText();
                  TextInput({ placeholder: '必填', text: $$this.cloneTouristInfo.name })
                    .touristTextInput()
                    .contentType(ContentType.PERSON_FULL_NAME);
                }.width('100%');

                Divider();

                Row() {
                  Text('手机号码').touristKeyText();
                  TextInput({ placeholder: '必填，请输入11位手机号码', text: $$this.cloneTouristInfo.phone })
                    .touristTextInput()
                    .contentType(ContentType.PHONE_NUMBER);
                }.width('100%');

                Divider();

                Row() {
                  Row({ space: 16 }) {
                    Text('证件类型').touristKeyText();
                    Row() {
                      Text(
                        this.cloneTouristInfo.cardType >= 0 ? CARD_TYPE_OPTIONS[this.cloneTouristInfo.cardType] :
                          '请选择')
                        .fontSize($r('sys.float.Body_L'))
                        .fontColor(
                          this.cloneTouristInfo.cardType >= 0 ? $r('sys.color.font_primary') :
                            $r('sys.color.font_secondary'))
                        .layoutWeight(1);
                      SymbolGlyph($r('sys.symbol.chevron_right'))
                        .width(12)
                        .height(24)
                        .fontSize(24)
                        .fontColor([$r('sys.color.icon_fourth')]);
                    }.layoutWeight(1).onClick(() => {
                      this.dialogController?.open();
                    });
                  };
                }.width('100%');

                Divider();

                Row() {
                  Text('证件号码').touristKeyText();
                  TextInput({ placeholder: '必填', text: $$this.cloneTouristInfo.cardNo })
                    .touristTextInput()
                    .contentType(this.getContentType);
                }.width('100%');
              }.borderRadius(16).backgroundColor($r('sys.color.comp_background_primary')).padding(12);

              Row({ space: 16 }) {
                Button(this.isEdit ? '删除' : '取消')
                  .layoutWeight(1)
                  .fontColor(this.isEdit ? $r('sys.color.warning') : $r('sys.color.multi_color_04'))
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    if (this.isEdit) {
                      this.delDialogController?.open();
                    } else {
                      this.goBack();
                    }
                  });

                Button('保存').layoutWeight(1).backgroundColor($r('sys.color.multi_color_04')).onClick(() => {
                  if (!this.vm.validate(this.getUIContext(), this.cloneTouristInfo)) {
                    return;
                  }

                  this.touristInfo.id = this.cloneTouristInfo.id;
                  this.touristInfo.name = this.cloneTouristInfo.name;
                  this.touristInfo.phone = this.cloneTouristInfo.phone;
                  this.touristInfo.cardType = this.cloneTouristInfo.cardType;
                  this.touristInfo.cardNo = this.cloneTouristInfo.cardNo;
                  this.addOrEditTourist(this.touristInfo, this.isEdit);
                  this.goBack();
                });
              }.width('100%').justifyContent(FlexAlign.Center);
            }.justifyContent(FlexAlign.SpaceBetween).layoutWeight(1);
          }
         .padding({
            bottom: this.windowBottomHeight,
            left: GridRowColSetting.getPageMargin(this.vm.currentBreakpoint),
            right: GridRowColSetting.getPageMargin(this.vm.currentBreakpoint),
          });
        };
      }
      .onBreakpointChange((breakpoint: string) => {
        this.vm.setBreakpoint(breakpoint);
      });
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onReady(() => {
      this.initData();
    });
  }
}