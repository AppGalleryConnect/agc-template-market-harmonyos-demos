import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { unifiedDataChannel } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { FONT_COLOR_LIST, FONT_SIZE_LIST, FONT_SPACE_LIST } from '../constants/Constants';
import { MarkOptions } from '../types/Types';
import { HistoryUtil } from '../utils/HistoryUtil';
import { FormatUtil } from '../utils/FormatUtil';
import { Logger } from '../utils/Logger';
import { contextUtil } from '../utils/ContextUtil'

const TAG = '[WaterMarksVM]';

@ObservedV2
export class WaterMarksVM {
  /** common **/
  suffix: string = '';
  iWidth: number = 0;
  iHeight: number = 0;
  markOptions: MarkOptions | undefined = undefined;
  tempDir: string = '';
  fileDir: string = '';
  @Trace fileName: string = '';
  @Trace pixelMap: image.PixelMap | undefined = undefined;
  @Trace pixelMapWithMarks: image.PixelMap | undefined = undefined;
  @Trace pixelMapWithMarksTemp: image.PixelMap | undefined = undefined;
  /** Edit **/
  @Trace tabIndex: number = 0;
  @Trace maskText: string = '';
  @Trace fontSize: number = 0;
  @Trace fontColor: string = '';
  @Trace fontOpacity: number = 0;
  @Trace fontSpace: number = 0;
  @Trace fontRotate: number = 0;
  /** Record **/
  @Trace optionsList: MarkOptions[] = [];
  @Trace selectedList: boolean[] = [];
  @Trace editing: boolean = false;
  colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

  @Monitor('maskText','fontSize','fontColor','fontOpacity','fontSpace','fontRotate')
  public optionsChange() {
    this._addWatermark();
  }

  private static _instance: WaterMarksVM;

  public static get instance() {
    if (!WaterMarksVM._instance) {
      WaterMarksVM._instance = new WaterMarksVM();
    }
    return WaterMarksVM._instance;
  }

  public resetParamsInShow() {
    this.suffix = '';
    this.fileName = '';
    this.pixelMap = undefined;
    this.pixelMapWithMarks = undefined;
    this.markOptions = undefined;
  }

  public getSandboxDir() {
    const ctx = contextUtil.getContext();
    this.tempDir = ctx!.tempDir;
    this.fileDir = ctx!.filesDir;
  }

  public resetParamsInEdit() {
    this.tabIndex = 0;
    this.pixelMapWithMarksTemp = this.pixelMapWithMarks;
    if (this.markOptions) {
      this.maskText = this.markOptions.text;
      this.fontSize = this.markOptions.size;
      this.fontColor = this.markOptions.color;
      this.fontOpacity = this.markOptions.opacity;
      this.fontSpace = this.markOptions.space;
      this.fontRotate = this.markOptions.rotate;
    } else {
      this.resetDrawParams();
    }
    this._addWatermark();
  }

  public resetParamsInRecords() {
    this.optionsList = HistoryUtil.getRecords();
    this.selectedList = Array.from<boolean>({ length: this.optionsList.length }).fill(false);
    this.editing = false;
  }

  public resetDrawParams() {
    this.maskText = '图片水印';
    this.fontSize = (FONT_SIZE_LIST[0] + FONT_SIZE_LIST[1]) / 2;
    this.fontColor = FONT_COLOR_LIST[0];
    this.fontOpacity = 1;
    this.fontSpace = (FONT_SPACE_LIST[0] + FONT_SPACE_LIST[1]) / 2;
    this.fontRotate = 315;
  }

  public choosePic() {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1;
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();

    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      const uri = photoSelectResult.photoUris.pop();
      if (uri) {
        Logger.info(TAG, 'photoViewPicker.select to file succeed and uri is:' + uri);
        this._copyToTempDir(uri);
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  public dragPic(event: DragEvent) {
    let dragData = event.getData();
    if (dragData === undefined) {
      return;
    }
    let record = dragData.getRecords();
    let key: string = record[0].getType();
    if (key === 'general.image') {
      this._copyToTempDir((record[0] as unifiedDataChannel.Image).imageUri);
    }
  }

  public confirm() {
    this.markOptions = {
      file: this.fileName,
      time: FormatUtil.getCurrentTimeString(),
      text: this.maskText,
      size: this.fontSize,
      color: this.fontColor,
      opacity: this.fontOpacity,
      space: this.fontSpace,
      rotate: this.fontRotate,
    };
    this.pixelMapWithMarks = this.pixelMapWithMarksTemp;
    if (this._copyToFileDir()) {
      HistoryUtil.addOrUpdateRecord(this.markOptions);
    }
  }

  public clickRecord(options: MarkOptions) {
    this.suffix = options.file.split('.').pop() ?? 'jpg';
    this.fileName = options.file;
    let file: fs.File | undefined = undefined;
    try {
      file = fs.openSync(this.fileDir + '/' + this.fileName);
      this._createPixelMap(file);
      this.markOptions = options;
      this.resetParamsInEdit();
      this.pixelMapWithMarks = this.pixelMapWithMarksTemp;
    } catch (e) {
      Logger.error(TAG, 'Edit record failed, Cause:' + JSON.stringify(e));
    } finally {
      if (file) {
        fs.close(file);
      }
    }
  }

  private _copyToTempDir(uri: string) {
    this.suffix = uri.split('.').pop() ?? 'jpg';
    this.fileName = Date.now().toString() + '.' + this.suffix;
    let file1: fs.File | undefined = undefined;
    let file2: fs.File | undefined = undefined;
    try {
      file1 = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      file2 = fs.openSync(this.tempDir + '/' + this.fileName, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.copyFileSync(file1.fd, file2.fd);
      this._createPixelMap(file2);
      return true;
    } catch (e) {
      Logger.error(TAG, 'Copy file to temp sandbox failed, Cause:' + JSON.stringify(e));
      return false;
    } finally {
      if (file1) {
        fs.close(file1);
      }
      if (file2) {
        fs.close(file2);
      }
    }
  }

  private _copyToFileDir() {
    let file1: fs.File | undefined = undefined;
    let file2: fs.File | undefined = undefined;
    try {
      if (fs.accessSync(this.fileDir + '/' + this.fileName)) {
        return true;
      }
      file1 = fs.openSync(this.tempDir + '/' + this.fileName, fs.OpenMode.READ_ONLY);
      file2 = fs.openSync(this.fileDir + '/' + this.fileName, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.copyFileSync(file1.fd, file2.fd);
      return true;
    } catch (e) {
      Logger.error(TAG, 'Copy file to file sandbox failed, Cause:' + JSON.stringify(e));
      return false;
    } finally {
      if (file1) {
        fs.close(file1);
      }
      if (file2) {
        fs.close(file2);
      }
    }
  }

  private _createPixelMap(file: fs.File) {
    try {
      const imageSource: image.ImageSource = image.createImageSource(file.fd);
      this.pixelMap = imageSource.createPixelMapSync();
      this.pixelMapWithMarks = undefined;
      this.pixelMapWithMarksTemp = undefined;
      this.markOptions = undefined;
      const info = this.pixelMap.getImageInfoSync();
      this.iWidth = contextUtil.getUiContext()!.px2vp(info.size.width);
      this.iHeight = contextUtil.getUiContext()!.px2vp(info.size.height);
    } catch (e) {
      Logger.error(TAG, 'Create pixelMap failed, Cause:' + JSON.stringify(e));
    }
  }

  private _addWatermark() {
    // 创建离屏画布
    const offScreenCanvas = new OffscreenCanvas(this.iWidth, this.iHeight);
    const offScreenContext = offScreenCanvas.getContext('2d');

    if (!offScreenContext) {
      Logger.error(TAG, '无法获取2D绘图上下文');
    }

    // 绘制原始图像
    offScreenContext.drawImage(this.pixelMap!, 0, 0, this.iWidth, this.iHeight);

    const r = parseInt(this.fontColor.slice(1, 3), 16);
    const g = parseInt(this.fontColor.slice(3, 5), 16);
    const b = parseInt(this.fontColor.slice(5, 7), 16);

    offScreenContext.fillStyle = `rgba(${r}, ${g}, ${b}, ${this.fontOpacity})`;
    offScreenContext.font = `${this.fontSize}vp`;
    offScreenContext.textBaseline = 'top';

    const textMetrics = offScreenContext.measureText(this.maskText);
    const textWidth = textMetrics.width;
    const textHeight = this.fontSize * 1.2;

    const angle = this.fontRotate * Math.PI / 180;

    const elementTotalWidth = textWidth + this.fontSpace;
    const elementTotalHeight = textHeight + this.fontSpace;

    const rotatedWidth = Math.abs(elementTotalWidth * Math.cos(angle)) +
    Math.abs(elementTotalHeight * Math.sin(angle));
    const rotatedHeight = Math.abs(elementTotalWidth * Math.sin(angle)) +
    Math.abs(elementTotalHeight * Math.cos(angle));

    const colCount = Math.ceil(this.iWidth / rotatedWidth) + 1;
    const rowCount = Math.ceil(this.iHeight / rotatedHeight) + 1;

    for (let col = 0; col < colCount; col++) {
      for (let row = 0; row < rowCount; row++) {
        offScreenContext.save();
        const x = col * rotatedWidth;
        const y = row * rotatedHeight;
        offScreenContext.translate(x, y);
        offScreenContext.rotate(angle);
        offScreenContext.fillText(this.maskText, -textWidth / 2, 0);
        offScreenContext.restore();
      }
    }
    this.pixelMapWithMarksTemp = offScreenContext.getPixelMap(0, 0, this.iWidth, this.iHeight);
  }
}