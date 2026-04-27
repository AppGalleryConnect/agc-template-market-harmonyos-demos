import { common } from '@kit.AbilityKit';
import { picker, fileIo as fs } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { MediaType, CastParams } from '../model/Index';
import { toastUtil } from '../util/ToastUtil';

@ComponentV2
export struct AudioPicker {
  @Param isCasting: boolean = false;
  @BuilderParam customContent: () => void;
  uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Event onSelect: (castParams: CastParams) => void = () => {

  };
  @Event onError: () => void = () => {

  };
  @Event onPicker: () => void = () => {

  };

  async getAudio(context: common.UIAbilityContext) {
    try {
      let audioSelectOptions = new picker.AudioSelectOptions();
      audioSelectOptions.maxSelectNumber = 1;
      let audioPicker = new picker.AudioViewPicker(context);
      audioPicker.select(audioSelectOptions).then((audioSelectResult: Array<string>) => {
        if (audioSelectResult.length > 0) {
          this.handleMetadata(audioSelectResult[0]);
        } else {
          this.onError();
        }

      }).catch((err: BusinessError) => {
        this.onError();
        Logger.error(`AudioViewPicker.select failed with err, code is: ${err.code}, message is: ${err.message}`);
      });
    } catch (error) {
      this.onError();
      const err: BusinessError = error as BusinessError;
      Logger.error(`AudioViewPicker failed with err, code is: ${err.code}, message is: ${err.message}`);
    }
  }

  async handleMetadata(filePath: string) {
    if (canIUse('SystemCapability.Multimedia.Media.AVMetadataExtractor')) {
      let file: fs.File | undefined = undefined;
      try {
        // 创建AVMetadataExtractor对象
        let avMetadataExtractor = await media.createAVMetadataExtractor();
        file = fs.openSync(filePath);
        // 设置fdSrc
        avMetadataExtractor.fdSrc = file;
        // 获取元数据
        let metadata = await avMetadataExtractor.fetchMetadata();
        const castParams: CastParams = {
          mediaType: MediaType.AUDIO,
          selectIndex: 0,
          mediaList: [{
            name: this.getAudioFileName(filePath),
            sortId: 1,
            id: this.getAudioFileName(filePath),
            url: filePath,
            head: '',
            duration: Number(metadata.duration),
            mediaType: MediaType.AUDIO,
          }],
        };
        this.onSelect(castParams);
        // 释放资源
        await avMetadataExtractor.release();
      } catch (e) {
        Logger.error(JSON.stringify(e));
      } finally {
        if (file) {
          fs.closeSync(file);
        }
      }
    }
  }

  // 根据文件路径获取文件名
  getAudioFileName(audioPath: string): string {
    const str = decodeURI(audioPath);
    return str.substring(str.lastIndexOf('/') + 1);
  }

  build() {
    Row() {
      this.customContent();
    }.onClick(() => {
      if (this.isCasting) {
        this.onPicker();
        this.getAudio(this.uiContext);
      } else {
        toastUtil.showToast('请先连接设备！');
      }
    });
  }
}