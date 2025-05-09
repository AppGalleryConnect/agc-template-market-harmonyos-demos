import { Catalog } from 'parse';

import { ReaderController } from '../controller/ReaderController';
import { emitter } from '@kit.BasicServicesKit';
import { Constants, LazyDataVM, WindowUtils } from 'common';


@ComponentV2
export struct ReaderToolCard {
  @Local isShowFontTool: boolean = false;
  @Local isShowCatalog: boolean = false;
  @Local isShowSpeech: boolean = false;
  @Local isShowColor: boolean = false;
  @Local isShowTurn: boolean = false;
  @Local isShowCSwiper: boolean = true;
  @Local cvm: LazyDataVM<Catalog> | undefined = undefined;
  @Local isShowSheet: boolean = false;
  @Local preIndex: number = 0;
  @Local selectStr: ResourceStr = $r('app.string.all_words');
  @Local selectArray: Array<SelectOption> = [];
  @Local screenLight: number = 0.5;
  @Local isReadingBySwiper: boolean = true;
  @Local isReadingBySingle: boolean = false;
  @Local curPageNumV: number = 0;
  @Local colorSelectedIndex: number = 0;
  @Local isCurChapter: boolean = false;
  @Param @Require @Once fontSize: number = 0;
  @Param @Require curPageNum: number;
  @Param @Require readController: ReaderController;

  aboutToAppear(): void {
    emitter.on(Constants.SWIPER_CHANGE, (eventData: emitter.EventData) => {
      // 监听到点击事件，关闭目录栏
      this.isShowCatalog = false;
    })

    this.curPageNumV = this.curPageNum;
    this.colorSelectedIndex = AppStorage.get('colorSelectedIndex') as number;
    this.isReadingBySingle = AppStorage.get('isReadingBySingle') as boolean;
    this.isReadingBySwiper = AppStorage.get('isReadingBySwiper') as boolean;
  }

  aboutToDisappear(): void {

  }

  saveTurningMode() {
    AppStorage.setOrCreate<boolean>('isReadingBySingle', this.isReadingBySingle);
    AppStorage.setOrCreate<boolean>('isReadingBySwiper', this.isReadingBySwiper);
  }
  @Builder
  buildFontModifySlider() {
    Row({ space: 5 }) {
      Image($r('app.media.ic_minus_font'))
        .height(30)
        .width(30)
        .onClick(() => {
          this.fontSize -= 5;
          this.readController?.modifyFont(this.curPageNum, this.fontSize);
          emitter.emit(Constants.FONT_CHANGE);
        })
      Column() {
        Slider({
          min: Constants.MIN_FONT_SIZE,
          max: Constants.MAX_FONT_SIZE,
          value: this.fontSize,
          step: 5,
          style: SliderStyle.InSet
        })
          .blockSize({ height: 30, width: 30 })
          .trackThickness(30)
          .blockColor($r('app.color.font_modifier_inner_color'))
          .trackColor($r('app.color.pure_white'))
          .selectedColor($r('app.color.slider_selected_color'))
          .showSteps(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.fontSize = value
            this.readController?.modifyFont(this.curPageNum, value);
            emitter.emit(Constants.FONT_CHANGE);
          })
      }
      .width('70%')

      Image($r('app.media.ic_add_font'))
        .height(30)
        .width(30)
        .onClick(() => {
          this.fontSize += 5;
          this.readController?.modifyFont(this.curPageNum, this.fontSize);
          emitter.emit(Constants.FONT_CHANGE);
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(80)
  }

  @Builder
  buildSwiperModifySlider() {
    Row({ space: 5 }) {
      Image($r('app.media.ic_arrow_left'))
        .height(20)
        .width(20)
        .onClick(() => {
          // todo 开发者可自行配置
          this.curPageNumV = this.curPageNum <= 10 ? 1 : this.curPageNum - 10
          let eventData: emitter.EventData = {
            data: {
              index: this.curPageNumV,
            }
          };
          emitter.emit(Constants.SWIPER_CHANGE, eventData);
        })
      Column() {
        Slider({
          min: Constants.MIN_PAGE_NUM,
          max: this.readController.getTotalNum(),
          value: this.curPageNumV,
          step: 10,
          style: SliderStyle.InSet
        })
          .blockSize({ height: 30, width: 30 })
          .trackThickness(30)
          .showTips(true)
          .blockColor($r('app.color.font_modifier_inner_color'))
          .trackColor($r('app.color.pure_white'))
          .selectedColor($r('app.color.slider_selected_color'))
          .onChange((value: number, mode: SliderChangeMode) => {
            // 手势离开滑块加载
            if (mode === SliderChangeMode.End) {
              let eventData: emitter.EventData = {
                data: {
                  index: value,
                }
              };
              emitter.emit(Constants.SWIPER_CHANGE, eventData);
              this.curPageNumV = value;
            }
          })
      }
      .width('70%')

      Image($r('app.media.ic_arrow_right'))
        .height(20)
        .width(20)
        .onClick(() => {
          this.curPageNumV = this.curPageNumV + 10 < this.readController.getTotalNum() ?
            this.curPageNumV + 10 : this.readController.getTotalNum()
          let eventData: emitter.EventData = {
            data: {
              index: this.curPageNumV,
            }
          };
          emitter.emit(Constants.SWIPER_CHANGE, eventData);
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(80)
  }

  @Builder
  buildLightModifySlider() {
    Row({ space: 5 }) {
      Image($r('app.media.ic_modify_color'))
        .height(40)
        .width(40)
      Column() {
        Slider({
          min: Constants.MIN_SCREEN_BRIGHT,
          max: Constants.MAX_SCREEN_BRIGHT,
          value: this.screenLight,
          step: 0.2,
          style: SliderStyle.OutSet
        })
          .blockColor($r('app.color.font_modifier_inner_color'))
          .trackColor($r('app.color.pure_white'))
          .selectedColor($r('app.color.slider_selected_color'))
          .onChange((value: number, mode: SliderChangeMode) => {
            this.screenLight = value;
            WindowUtils.setWindowBright(this.screenLight);
          })
      }
      .width(300)

      Column()
        .height(40)
        .width(40)
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(10)
    .height(50)
  }

  @Builder
  buildTurnModifySlider() {
    Column() {
      Row() {
        Text($r('app.string.reading_with_swiper'))
        Toggle({ type: ToggleType.Switch, isOn: this.isReadingBySwiper })
          .selectedColor($r('app.color.slider_selected_color'))
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.isReadingBySwiper = true;
              this.isReadingBySingle = false;
            } else {
              this.isReadingBySwiper = false;
              this.isReadingBySingle = true;
            }
            this.saveTurningMode();
          })
          .width(40)
          .height(20)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(50)

      Row() {
        Text($r('app.string.reading_with_single'))
        Toggle({ type: ToggleType.Switch, isOn: this.isReadingBySingle })
          .width(40)
          .height(20)
          .selectedColor($r('app.color.slider_selected_color'))
          .onChange((isOn: boolean) => {
            if (isOn) {
              this.isReadingBySingle = true;
              this.isReadingBySwiper = false;
            } else {
              this.isReadingBySingle = false;
              this.isReadingBySwiper = true;
            }
            this.saveTurningMode()
          })
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(50)
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(100)
  }

  @Builder
  buildCatalog(c: Catalog, prvc: Catalog, index: number) {
    Column() {
      Row() {
        Text(`${index + 1}. ${c.title}`)
          .fontSize(18)
          .width('90%')
          .fontColor(this.isInCurCatalog(c.index) ? Color.Blue : Color.Black)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
      }

      Divider()
        .margin({ top: 5 })
    }
    .margin({ left: 20, right: 20 })
    .onClick(() => {
      let jumpIndex = 1;
      if (prvc !== undefined) {
        jumpIndex = prvc.index + 1;
      }
      let eventData: emitter.EventData = {
        data: {
          index: jumpIndex, // 前一个章节的末尾
        }
      };
      emitter.emit(Constants.SWIPER_CHANGE, eventData);
    })
  }

  @Builder
  buildCatalogCard() {
    Column() {
      Row() {
        Text(`共${this.cvm?.totalCount()}章`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .width(Constants.FULL_SIZE)
      }
      .padding({
        top: 10,
        bottom: 20,
        left: 15,
        right: 15
      })

      // 全部按钮删除？
      List({ space: 30 }) {
        ForEach(this.cvm?.getAllData(), (c: Catalog, index: number) => {
          ListItem() {
            if (this.cvm) {
              this.buildCatalog(c, this.cvm.getData(index - 1), index % this.cvm.totalCount());
            }
          }
        },(item: string) => new Date().toString())
      }
    }
  }

  @Builder
  colorCircle(color: ResourceStr | ResourceColor, index: number) {
    Column()
      .height(30)
      .width(30)
      .backgroundColor(color)
      .borderRadius(100)
      .padding({ left: 18, right: 18 })
      .onClick(() => {
        this.colorSelectedIndex = index;
        let eventData: emitter.EventData = {
          data: {
            color: color,
          }
        };
        AppStorage.setOrCreate<number>('colorSelectedIndex', index);
        emitter.emit(Constants.VIEW_COLOR_CHANGE, eventData);
      })
      .borderColor($r('app.color.ic_color'))
      .borderWidth(this.colorSelectedIndex === index ? 0.1 : 0)
  }

  @Builder
  buildModifyColor() {
    Column() {
      // 亮度调整
      this.buildLightModifySlider();
      // 颜色调整
      Row({ space: 20 }) {
        this.colorCircle($r('app.color.reader_view_background_0'), 0)
        this.colorCircle($r('app.color.reader_view_background_1'), 1)
        this.colorCircle($r('app.color.reader_view_background_2'), 2)
        this.colorCircle($r('app.color.reader_view_background_3'), 3)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(50)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ top: 10, left: 18, right: 18 })
    .height(130)
  }

  isInCurCatalog(index: number): boolean {
    if (this.isCurChapter) {
      return false;
    }
    if (this.curPageNum <= index && this.curPageNum >= this.preIndex - 1) {
      this.isCurChapter = true;
      return true;
    } else {
      this.preIndex = index;
      return false;
    }
  }

  selectTool(isShowCatalog: boolean, isShowFontTool: boolean, isShowColor: boolean,
    isShowTurn: boolean, isShowCSwiper: boolean) {
    this.isShowFontTool = isShowFontTool;
    this.isShowCatalog = isShowCatalog;
    this.isShowColor = isShowColor;
    this.isShowTurn = isShowTurn;
    this.isShowCSwiper = isShowCSwiper;
  }

  build() {
    Stack() {
      Column() {
        if (this.isShowCSwiper) {
          this.buildSwiperModifySlider();
        }

        if (this.isShowFontTool) {
          this.buildFontModifySlider();
        }

        if (this.isShowColor) {
          this.buildModifyColor();
        }

        if (this.isShowTurn) {
          this.buildTurnModifySlider();
        }

        Row() {
          Image($r('app.media.ic_chapter'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Auto)
            .onClick(() => {
              if (!this.isShowCatalog) {
                // 获取当前章节信息
                this.cvm = this.readController.getCatalog();
                this.selectTool(true, false, false, false, false);
              } else {
                this.isShowCatalog = false;
              }
            })
          Image($r('app.media.ic_font'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Auto)
            .onClick(() => {
              if (!this.isShowFontTool) {
                this.selectTool(false, true, false, false, false);
              } else {
                this.isShowFontTool = false;
              }
            })
          Image($r('app.media.ic_modify_color'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Auto)
            .onClick(() => {
              if (!this.isShowColor) {
                this.selectTool(false, false, true, false, false);
              } else {
                this.isShowColor = false;
              }
            })
          Image($r('app.media.ic_modify_turn'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Auto)
            .onClick(() => {
              if (!this.isShowTurn) {
                this.selectTool(false, false, false, true, false)
              } else {
                this.isShowTurn = false;
              }
            })
        }
        .width(Constants.FULL_SIZE)
        .padding({ left: 25, right: 25, bottom: 30 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .bindSheet($$this.isShowCatalog, this.buildCatalogCard(), {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 800],
        height: SheetSize.FIT_CONTENT,
        preferType: SheetType.BOTTOM,
        title: { title: $r('app.string.catalog') },
      })
    }
    .width(Constants.FULL_SIZE)
    .backgroundColor(Color.White)
    .align(Alignment.BottomEnd)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}