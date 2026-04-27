import { display, PersistenceV2 } from '@kit.ArkUI';
import { pasteboard, systemDateTime } from '@kit.BasicServicesKit';
import BigNumber from 'bignumber.js';
import arEngine from 'libentry.so';
import { UtilLog } from '@hw-agconnect/util-log';
import { ENGINE_UPDATE_INTERVAL, MeasureType, SPACE_MAP } from '../constant/Constant';
import { HistoryList } from '../model/Index';

@ObservedV2
export class ARMeasureVM {
  private static _instance: ARMeasureVM;
  @Trace isSupported: boolean = true;
  @Trace pageInfos: NavPathStack = new NavPathStack();
  @Trace isShowHistoryPicker: boolean = false;
  @Trace isShowMeasureHint: boolean = false;
  @Trace xComponentId: string = 'ARSemanticDense';
  @Trace interval: number = -1;
  @Trace semanticDenseMode: number = 1;
  @Trace hasMeasured: boolean = false;
  @Trace hasPermission: boolean = false;
  @Trace rotation: number = display.getDefaultDisplaySync().rotation;
  @Trace volume: string = '';
  @Trace volumeIdStr: string = systemDateTime.getTime(false).toString() + this.xComponentId;
  @Trace spaceIdStr: string = (systemDateTime.getTime(false) + 1).toString() + this.xComponentId;
  @Trace measureHistory: HistoryList =
    PersistenceV2.connect(HistoryList, 'HistoryList', () => new HistoryList())!;
  @Trace volumeData: string[] = [];
  @Trace spaceData: string[] = [];

  public static get instance() {
    if (!ARMeasureVM._instance) {
      ARMeasureVM._instance = new ARMeasureVM();
    }
    return ARMeasureVM._instance;
  }

  init(context: Context, idStr: string) {
    try {
      arEngine.init(context.resourceManager);
      let config: Int32Array = new Int32Array([1, this.rotation, 2, this.semanticDenseMode]);
      arEngine.start(idStr, config);
    } catch (e) {
      // 不支持AR测量
      this.isSupported = false;
      UtilLog.error(0xFF00, 'ARMeasure', `Init XComponent failed ${JSON.stringify(e)}`);
    }
  }

  switchMode(context: Context) {
    if (this.isSupported) {
      arEngine.hide(this.semanticDenseMode === MeasureType.VOLUME ? this.spaceIdStr : this.volumeIdStr);
      arEngine.stop(this.semanticDenseMode === MeasureType.VOLUME ? this.spaceIdStr : this.volumeIdStr);
      this.destroy();
      this.init(context, this.semanticDenseMode === MeasureType.VOLUME ? this.volumeIdStr : this.spaceIdStr);
      this.load(this.semanticDenseMode === MeasureType.VOLUME ? this.volumeIdStr : this.spaceIdStr);
      this.semanticDenseMode === MeasureType.VOLUME ? this.spaceData = [] : this.volumeData = [];
      arEngine.show(this.semanticDenseMode === MeasureType.VOLUME ? this.volumeIdStr : this.spaceIdStr);
      this.hasMeasured = false;
      this.volume = '';
    }
  }

  destroy() {
    if (this.interval !== -1) {
      clearInterval(this.interval);
      this.interval = -1;
    }
  }

  load(idStr: string) {
    try {
      this.interval = setInterval(() => {
        arEngine.update(idStr);
        this.volume = arEngine.getVolume(idStr);
        UtilLog.info(0xFF00, 'ARMeasure', `ARMeasure result is ${this.volume}`);
        if (this.semanticDenseMode === MeasureType.VOLUME) {
          let data = this.volume.split(':')[1];
          if (data.length > 1) {
            this.hasMeasured = true;
            UtilLog.info(0xFF00, 'ARMeasure', `Volume Measure success with data ${data}`);
            this.handleFormatVolume(data);
          }
        } else {
          // 实际为空间数据
          let data = this.volume.split(':')[1];
          if (data.length > 1) {
            this.hasMeasured = true;
            UtilLog.info(0xFF00, 'ARMeasure', `Space Measure success with data ${data}`);
            this.handleFormatSpace(data);
          }
        }
      }, ENGINE_UPDATE_INTERVAL);
    } catch (e) {
      UtilLog.error(0xFF00, 'ARMeasure', `Load XComponent failed ${JSON.stringify(e)}`);
    }
  }

  handleFormatSpace(data: string) {
    let separateData = data.split('|');
    UtilLog.info(0xFF00, 'ARMeasure', `measure data length is ${separateData.length}`);
    if (separateData.length === 3) {
      let left = separateData[0].substring(0, separateData[0].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData left is  ${left}`);
      let right = separateData[1].substring(0, separateData[1].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData right is  ${right}`);
      let bottom = separateData[2].substring(0, separateData[2].length - 2);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData bottom is  ${bottom}`);
      this.spaceData = ['', bottom, left, right, ''];
    } else if (separateData.length === 4) {
      let left = separateData[0].substring(0, separateData[0].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData left is  ${left}`);
      let right = separateData[1].substring(0, separateData[1].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData right is  ${right}`);
      let top = separateData[2].substring(0, separateData[2].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData top is  ${top}`);
      let bottom = separateData[3].substring(0, separateData[3].length - 2);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData bottom is  ${bottom}`);
      this.spaceData = [top, bottom, left, right, ''];
    } else {
      let left = separateData[0].substring(0, separateData[0].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData left is  ${left}`);
      let right = separateData[1].substring(0, separateData[1].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData right is  ${right}`);
      let top = separateData[2].substring(0, separateData[2].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData top is  ${top}`);
      let bottom = separateData[3].substring(0, separateData[3].length - 1);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData bottom is  ${bottom}`);
      let back = separateData[4].substring(0, separateData[4].length - 2);
      UtilLog.info(0xFF00, 'ARMeasure', `spaceData back is  ${back}`);
      this.spaceData = [top, bottom, left, right, back];
    }
    UtilLog.info(0xFF00, 'ARMeasure', `spaceData is ${this.spaceData}`);
  }

  handleFormatVolume(data: string) {
    let separateData = data.split('|');
    UtilLog.info(0xFF00, 'ARMeasure', `separateData is ${separateData}`);
    let length = separateData[0].substring(0, separateData[0].length - 1);
    UtilLog.info(0xFF00, 'ARMeasure', `volumeData length is  ${length}`);
    let width = separateData[1].substring(0, separateData[1].length - 1);
    UtilLog.info(0xFF00, 'ARMeasure', `volumeData width is  ${length}`);
    let height = separateData[2].substring(0, separateData[2].length - 2);
    UtilLog.info(0xFF00, 'ARMeasure', `volumeData height is  ${length}`);
    this.volumeData = [length, width, height];
    UtilLog.info(0xFF00, 'ARMeasure', `volumeData is ${this.volumeData}`);
  }

  getText(record: string[], type: MeasureType) {
    let text = '';
    if (type === MeasureType.VOLUME) {
      text = `长：${new BigNumber(Number(new BigNumber(record[0])) *
        100).decimalPlaces(1)}cm 宽：${new BigNumber(Number(new BigNumber(record[1])) *
        100).decimalPlaces(1)}cm 高：${new BigNumber(Number(new BigNumber(record[2])) * 100).decimalPlaces(1)}cm`;
    } else {
      for (let i = 0; i < record.length; i++) {
        if (!record[i].length) {
          continue;
        }
        text += `${SPACE_MAP.get(i)}：${new BigNumber(Number(new BigNumber(record[i])) *
          100).decimalPlaces(1)}cm `;
      }
    }
    return text;
  }

  getFormatTime(date: Date) {
    return `${date.getFullYear()}.${(date.getMonth() + 1).toString().padStart(2, '0')}.${date.getDate()
      .toString()
      .padStart(2, '0')} ${date.getHours()
      .toString()
      .padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}:${date.getSeconds()
      .toString()
      .padStart(2, '0')}`;
  }

  copyText(uiContext: UIContext, orderNo: string) {
    try {
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, orderNo);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteboardData);
      systemPasteboard.getData().then((data) => {
        if (data) {
          uiContext.getPromptAction().showToast({ message: '复制成功' });
        } else {
          uiContext.getPromptAction().showToast({ message: '复制失败' });
        }
      });
    } catch (e) {
      UtilLog.error(`copyText failed with error ${JSON.stringify(e)}`)
    }
  }

  save() {
    if (this.volumeData.length) {
      this.measureHistory.list.unshift({
        type: this.semanticDenseMode,
        record: this.volumeData,
        time: new Date(),
      });
    }
    if (this.spaceData.length) {
      this.measureHistory.list.unshift({
        type: this.semanticDenseMode,
        record: this.spaceData,
        time: new Date(),
      });
    }
  }

  saveMeasureRecord() {
    this.save();
    // 清空测量数据
    this.volumeData = [];
    this.spaceData = [];
    this.hasMeasured = false;
  }

  saveManually() {
    this.save();
  }
}