import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import image from '@ohos.multimedia.image';
import { VideoEditVM } from '../viewmodel/VideoEditVM';
import { TextInfo } from '../model/Index';

@ComponentV2
export struct TextInputCanvas {
  vm: VideoEditVM = VideoEditVM.instance;
  @Param textInfo: TextInfo = new TextInfo();
  @Param isFinish: boolean = false;
  @Event setImageURI: (filePath: string, wordUri: string) => void = () => {
  };
  @Local pixelMap: image.PixelMap | null = null;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private canvasWidth: number = 250;
  private canvasHeight: number = 100;

  @Monitor('textInfo.text')
  onTextChange() {
    this.drawTextOnCanvas();
  }

  @Monitor('textInfo.currentColor')
  onTextColorChange() {
    this.drawTextOnCanvas();
  }

  @Monitor('textInfo.isItalics')
  onTextItalicChange() {
    this.drawTextOnCanvas();
  }

  @Monitor('textInfo.isBold')
  onTextBoldChange() {
    this.drawTextOnCanvas();
  }

  @Monitor('textInfo.opacity')
  onTextOpacityChange() {
    this.drawTextOnCanvas();
  }

  @Monitor('textInfo.fontSize')
  onTextFontSizeChange() {
    this.drawTextOnCanvas();
  }

  @Monitor('isFinish')
  onInputComplete() {
    if (this.isFinish) {
      this.canvasToPixelMap();
    }
  }

  build() {
    Column({ space: 20 }) {
      // 画布绘制文字
      Canvas(this.context)
        .constraintSize({
          minHeight: 50,
          maxHeight: 100,
          minWidth: 100,
          maxWidth: 250,
        })
        .onReady(() => {
          this.drawTextOnCanvas();
        }).onClick(() => {
        if (this.vm.textInfo.text) {
          this.vm.textPicker = true;
        }
      });
    };
  }

  drawTextOnCanvas() {
    if (!this.context) {
      return;
    }
    const context = this.context;

    // 清空画布
    context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    const fontStyle = this.vm.textInfo.isItalics ? 'italic' : 'normal';
    const fontWeight = this.vm.textInfo.isBold ? 'bold' : 'normal';
    const fontSize = `${this.getUIContext().vp2px(this.vm.textInfo.fontSize)}px`;

    // 设置文字样式
    context.font = `${fontStyle} ${fontWeight} ${fontSize} sans-serif`;
    context.fillStyle = this.vm.textInfo.currentColor;
    context.globalAlpha = this.vm.textInfo.opacity;
    context.textAlign = 'left';
    context.textBaseline = 'top';

    // 绘制文字（坐标为画布中心）
    let currentLine = '';
    let currentY = 0;
    for (let i = 0; i < this.textInfo.text.length; i++) {
      const char = this.textInfo.text[i];
      const testLine = currentLine + char;
      const textWidth = context.measureText(testLine).width;
      // 遇见换行符换行
      if (char === '\n') {
        context.fillText(currentLine, 0, currentY);
        currentLine = '';
        currentY += 25;
        continue;
      }
      // 超出宽度则换行
      if (textWidth > this.canvasWidth) {
        context.fillText(currentLine, 0, currentY);
        currentLine = char;
        currentY += 25;
      } else {
        currentLine = testLine;
      }
    }

    UtilLog.info(0xFF00, 'VideoClip', `draw text : ${this.textInfo.text}`);

    // 绘制最后一行
    if (currentLine) {
      context.fillText(currentLine, 20, currentY);
    }
  }

  // 画布转为PixelMap并且保存
  async canvasToPixelMap() {
    if (!this.context) {
      return;
    }
    let fileFd: number = 0;
    try {
      // 转换为png格式，质量0.8
      const dataUrl = this.context.toDataURL('image/png', 0.8);

      // 解析base64数据
      const base64Data = dataUrl.split(',')[1];
      const buffer = await this.base64ToArrayBuffer(base64Data);

      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;

      let timestamp = Date.now();
      const filePath = context.filesDir + '/canvas_image' + timestamp + '.png';
      // 写入文件
      try {
        let fileDescriptor = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fileFd = fileDescriptor.fd;
        await fs.write(fileDescriptor.fd, buffer);
        this.setImageURI(filePath, dataUrl);
      } catch (error) {
        UtilLog.error(0xFF00, 'VideoClip', `open file error : ${error}`);
      } finally {
        fs.closeSync(fileFd);
      }
    } catch (err) {
      UtilLog.error(0xFF00, 'VideoClip', 'save fail');
    }
  }

  /**
   * base64ToArrayBuffer
   *
   * @param base64Str
   * @returns ArrayBuffer
   * @note 如果传base64的图片字符串，需要将“data:image/png;base64,”前缀剪切掉
   */
  async base64ToArrayBuffer(base64Str: string): Promise<ArrayBuffer> {
    let base64 = new util.Base64Helper();
    let uint8Array: Uint8Array = await base64.decode(base64Str);
    let buffer: ArrayBuffer = uint8Array.buffer.slice(0, uint8Array.byteLength);
    return buffer;
  }
}


