import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { COLOR_LIST, HIGHLIGHT_COLOR_FILTER, ORIGIN_COLOR_FILTER, PHOTO_MAX_COUNT,
  PHOTO_MAX_SIZE } from '../commons/Constant';
import { EditorController } from '../controller/EditorController';
import { PickerUtil } from '../utils/PickerUtil';
import { AlignmentInfo } from '../commons/Interface';
import { ImageUtils } from '../utils/ImageUtils';

@ComponentV2
export struct RichTextToolBar {
  @Param editorController: EditorController = new EditorController();
  @Param showToolBar: boolean = false

  async handleSelectPhoto(imageUri: string) {
    // 获取富文本中的所有图片
    const htmlContent = this.editorController.richTextContent;
    const imgList: string[] = ImageUtils.findImgSrcList(htmlContent);
    // 校验图片个数
    if (imgList.length >= PHOTO_MAX_COUNT) {
      this.getUIContext().getPromptAction().showToast({
        message: `图片总数超过${PHOTO_MAX_COUNT}个，已达上限`
      })
      return;
    }

    // 校验图片大小
    let size: number = 0;
    try {
      for (let i = 0; i < imgList.length; i++) {
        const filePath = imgList[i].replace('file:///', '');
        const stat = fileIo.statSync(filePath);
        if (stat) {
          size += stat.size;
        }
      }
    } catch (e) {
      UtilLog.error('[RichTextToolBar]', `get file stat failed. error: ${JSON.stringify(e)}`)
    }
    const sizeGB = this.bytesToGB(size);
    if (sizeGB >= PHOTO_MAX_SIZE) {
      this.getUIContext().getPromptAction().showToast({
        message: `图片总大小超过${PHOTO_MAX_SIZE}GB，已达上限`
      })
      return;
    }

    // 图片压缩并保存到沙箱
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const imgName = new Date().getTime() + '.jpg';
    const sandboxUri = await ImageUtils.compressImage(context, imageUri, imgName);
    this.editorController.htmlModel.htmlImgSandboxUris.push(sandboxUri)
    this.editorController.insertImage(sandboxUri);

    setTimeout(() => {
      let pageHeight = this.editorController.webviewController.getPageHeight();
      this.editorController.webviewController.scrollTo(0, Number(pageHeight) + 320, 100);
    }, 300)
  }

  bytesToGB(bytes: number = 0) {
    return bytes / 1024 / 1024 / 1024
  }

  build() {
    Column() {
      if (this.editorController.showToolBarIndex === 1) {
        this.colorPalette();
      } else if (this.editorController.showToolBarIndex === 2) {
        this.paragraphFormat();
      }

      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        // 调色盘图标
        Image($r('app.media.font_color_size'))
          .width(24)
          .fillColor(COLOR_LIST[this.editorController.currentColor])
          .onClick(() => {
            if (this.editorController.showToolBarIndex !== 1) {
              this.editorController.showToolBarIndex = 1;
            } else {
              this.editorController.showToolBarIndex = 0;
            }
          })

        // 段落对齐图标
        Image(this.editorController.paragraphAlignments[this.editorController.currentAlignment].icon)
          .width(24)
          .onClick(() => {
            if (this.editorController.showToolBarIndex !== 2) {
              this.editorController.showToolBarIndex = 2;
            } else {
              this.editorController.showToolBarIndex = 0;
            }
          });

        // 文本加粗图标
        Image($r('app.media.ic_bold'))
          .width(24)
          .colorFilter(this.editorController.currentBold ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)// 当前图标高亮
          .onClick(() => {
            this.editorController.currentBold = !this.editorController.currentBold;
            this.editorController.bold()
          });

        // 文本斜体图标
        Image($r('app.media.ic_notepad_italic'))
          .width(24)
          .colorFilter(this.editorController.currentItalics ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)// 当前图标高亮
          .onClick(() => {
            this.editorController.currentItalics = !this.editorController.currentItalics;
            this.editorController.italic()
          });

        // 文本下划线图标
        Image($r('app.media.ic_underline'))
          .width(24)
          .colorFilter(this.editorController.showUnderline ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
          .onClick(() => {
            this.editorController.showUnderline = !this.editorController.showUnderline;
            this.editorController.underline();
          });

        // 文本删除线图标
        Image($r('app.media.ic_deleteline'))
          .width(24)
          .colorFilter(this.editorController.showLineThrough ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
          .onClick(() => {
            this.editorController.showLineThrough = !this.editorController.showLineThrough;
            this.editorController.strikethrough();
          });

        // 选择图片图标
        SymbolGlyph($r('sys.symbol.picture_fill'))
          .fontSize(24)
          .onClick(() => {
            PickerUtil.selectPhoto({
              maxSelectNumber: 1,
            }).then((uris) => {
              const imageUri = uris[0];
              if (!imageUri) {
                return
              }

              this.handleSelectPhoto(imageUri)
            });
          });
      }
      .height(60)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .backgroundColor('#EDEFF5')
    }
    .visibility(this.showToolBar ? Visibility.Visible : Visibility.None)
  }

  // 调色盘选项栏
  @Builder
  colorPalette() {
    Column(){
      Row() {
        Text('A').fontSize(10).fontColor($r('sys.color.font_secondary'));
        Blank();
        Row() {
          Slider({
            value: this.editorController.fontSize,
            min: 1, //滑动最小值
            max: 9, //滑动最大值
            step: 2, //步长
            style: SliderStyle.InSet,
          })
            .trackThickness(20)
            // 刻度颜色
            .stepColor($r('sys.color.comp_background_secondary'))
            // 滑轨背景色
            .trackColor($r('sys.color.comp_background_secondary'))
            // 以滑动部分颜色
            .selectedColor($r('sys.color.comp_background_emphasize'))
            // 显示步长刻度
            .showSteps(true)
            .blockStyle({ type: SliderBlockType.IMAGE, image: $r('app.media.font_setting') })
            .blockSize({
              width: $r('app.float.rich_editor_block_size'),
              height: $r('app.float.rich_editor_block_size')
            })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.editorController.changeFontSize(value)
            })
        }
        .width('90%')

        Blank();

        Text('A').fontSize(16).fontColor($r('sys.color.font_secondary'));
      }
      .width('100%')
      .height(50)
      .padding({ left: '4%', right: '4%' })

      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        ForEach(COLOR_LIST, (color: ResourceColor, index: number) => {
          Stack() {
            Circle({ width: 16, height: 16 }).fill(color);

            Circle({ width: 24, height: 24 })
              .fillOpacity(0)
              .borderWidth(2)
              .borderRadius(12)
              .borderColor(this.editorController.currentColor === index ? Color.Red : Color.Black);
          }
          .onClick(() => {
            this.editorController.showToolBarIndex = 0;
            this.editorController.currentColor = index;
            this.editorController.changeFontColor(COLOR_LIST[index])
          });
        }, (color: ResourceColor) => JSON.stringify(color));
      }
      .width('100%')
      .height(50);
    }
    .width('100%')
    .height(100);
  }

  // 段落样式选项栏
  @Builder
  paragraphFormat() {
    Flex({
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
    }) {
      ForEach(this.editorController.paragraphAlignments, (item: AlignmentInfo, index: number) => {
        Image(item.icon)
          .width(24)
          .colorFilter(this.editorController.currentAlignment === index ? HIGHLIGHT_COLOR_FILTER :
            ORIGIN_COLOR_FILTER)// 当前段落样式高亮
          .onClick(item.click);
      }, (item: AlignmentInfo) => JSON.stringify(item));
    }
    .width('100%')
    .height(56);
  }
}