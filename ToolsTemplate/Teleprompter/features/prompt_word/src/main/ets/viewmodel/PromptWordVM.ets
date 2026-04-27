import { AppStorageV2, PersistenceV2, PromptAction, UIContext } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';
import { camera, cameraPicker } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { textRecognition } from '@kit.CoreVisionKit';
import { common } from '@kit.AbilityKit';
import { fileIo, picker, ReadOptions } from '@kit.CoreFileKit';
import { CueWordsItem, CueWordsList, PersistenceCueWords } from './CueWordsItemModel';
import { phoneRouterControl } from 'oh_router';
import { NewPromptWordPageBuilder } from '../views/NewPromptWordPage';
import { GlobalContext, RouterMap, TCLogger } from 'common';

@ObservedV2
export class PromptWordVM {
  logTag: string = 'SetUpPage';
  @Trace cueWordsList: CueWordsList = AppStorageV2.connect(CueWordsList, 'CueWordsList', () => new CueWordsList())!
  @Trace persistenceCueWords: PersistenceCueWords =
    PersistenceV2.connect(PersistenceCueWords, () => new PersistenceCueWords())!
  @Trace cueWordItem?: CueWordsItem = new CueWordsItem('', '', '', '');
  @Trace dialogId: number = 0
  ctx: UIContext = GlobalContext.getUIContext();
  promptAction: PromptAction = new UIContext().getPromptAction()
  hostContext: Context | undefined = new UIContext().getHostContext()

  //从持久化字符串获取提词列表数据重新转化成题词列表类
  getPersistenceCueWords() {
    let persistenceCueWords = JSON.stringify(this.persistenceCueWords.content)
    TCLogger.info('PersistenceCueWords' + persistenceCueWords)
    if (persistenceCueWords !== '""') {
      let list: CueWordsItem[] = JSON.parse(this.persistenceCueWords.content)
      list.forEach(item => {
        this.cueWordsList.add(new CueWordsItem(item.__ob_id, item.__ob_title, item.__ob_content, item.time))
      })
      TCLogger.info('PersistenceCueWords' + JSON.stringify(this.cueWordsList))
    }
  }

  // 删除弹框
  showDeleteAlert(data: CueWordsItem) {
    this.ctx.showAlertDialog({
      message: '确定要删除吗？',
      height: 131,
      width: 284,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          fontColor: 'rgba(0, 0, 0, 0.60)',
          action: () => {
          }
        },
        {
          value: '确认',
          action: () => {
            this.cueWordsList.delete(data.id)
          }
        }
      ]
    })
  }

  // 导入txt转文字
  importFileTxt() {
    try {
      let context = this.hostContext as common.Context;
      let documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1; // 最多选择5个文件
      documentSelectOptions.fileSuffixFilters = [
        '文档|.txt'
      ];
      let documentPicker = new picker.DocumentViewPicker(context);
      documentPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
        let uri: string = documentSelectResult[0];
        let content = this.readFileContent(uri)
        if (content) {
          let data = new CueWordsItem('', '', content, '')
          phoneRouterControl.jumpPage({
            pageName: RouterMap.NEW_PROMPT_WORD_PAGE,
            builder: wrapBuilder(NewPromptWordPageBuilder),
            param: data
          })
        } else {
          this.promptAction.showToast({ message: '文档导入失败' })
        }
        this.promptAction.closeCustomDialog(this.dialogId)
      }).catch((err: BusinessError) => {
        this.promptAction.closeCustomDialog(this.dialogId)
        TCLogger.error('DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      this.promptAction.closeCustomDialog(this.dialogId)
      TCLogger.error('DocumentViewPicker failed with err: ' + JSON.stringify(err));
    }
  }

  // 拍照识别文字
  async importByCamera() {
    try {
      let resultUri = await this.takePhoto()
      if (resultUri) {
        let content = await this.loadImage(resultUri)
        if (content) {
          this.promptAction.closeCustomDialog(this.dialogId)
          let data = new CueWordsItem('', '', content, '')
          phoneRouterControl.jumpPage({
            pageName: RouterMap.NEW_PROMPT_WORD_PAGE,
            builder: wrapBuilder(NewPromptWordPageBuilder),
            param: data
          })
        }
      }
    } catch (error) {
      this.promptAction.closeCustomDialog(this.dialogId)
    }
  }

  private readFileContent(uri: string) {
    try {
      const sandboxPath = `${this.hostContext?.filesDir}/temp.txt`
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);

      fileIo.copyFileSync(file.fd, sandboxPath); // 复制到沙箱
      // 获取文件大小（用于创建缓冲区）
      const stat = fileIo.statSync(sandboxPath);
      // let fileStat = fileIo.statSync(sandboxPath)
      TCLogger.info(`文件大小: ${stat.size} 字节`)
      // 创建一个等于文件大小的ArrayBuffer对象，用于存储从文件中读取的数据
      let arrayBuffer = new ArrayBuffer(stat.size);
      // 设置读取的偏移量和长度
      let readOptions: ReadOptions = {
        offset: 0,
        length: arrayBuffer.byteLength
      };
      // 读取文件内容到ArrayBuffer对象中，并返回实际读取的字节数
      let readLen = fileIo.readSync(file.fd, arrayBuffer, readOptions);
      // 将ArrayBuffer对象转换为Buffer对象，并转换为字符串输出
      let buf = buffer.from(arrayBuffer, 0, readLen);
      TCLogger.info(`the content of file: ${buf.toString()}`)
      // 关闭文件
      fileIo.closeSync(file);
      return buf.toString()
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      TCLogger.error('readFileContent err: ' + JSON.stringify(err));
      return ''
    }
  }

  private async takePhoto() {
    try {
      let context = this.hostContext as common.Context;
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(context,
        [cameraPicker.PickerMediaType.PHOTO], pickerProfile);
      TCLogger.info('the pick pickerResult is:' + JSON.stringify(pickerResult));
      return pickerResult.resultUri
    } catch (error) {
      let err = error as BusinessError;
      TCLogger.error(`the pick call failed. error code: ${err.code}`);
      return ''
    }
  }

  private async loadImage(uri: string) {
    const sandboxPath = `${this.hostContext?.filesDir}/temp.jpg`
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    fileIo.copyFileSync(file.fd, sandboxPath); // 复制到沙箱
    try {
      const imageSource = image.createImageSource(sandboxPath);
      const pixelMap = await imageSource.createPixelMap();

      const visionInfo: textRecognition.VisionInfo = {
        pixelMap: pixelMap
      };

      let textConfiguration: textRecognition.TextRecognitionConfiguration = {
        isDirectionDetectionSupported: true
      };
      let recognitionString: string = '';
      if (canIUse('SystemCapability.AI.OCR.TextRecognition')) {
        await textRecognition.recognizeText(visionInfo, textConfiguration).then((textRecognitionResult) => {
          if (textRecognitionResult.value === '') {
            recognitionString = ''
          } else {
            recognitionString = textRecognitionResult.value;
          }
        })
        pixelMap.release();
        imageSource.release();
      } else {
        recognitionString = ''
      }
      TCLogger.info('recognitionString' + recognitionString)
      return recognitionString
    } catch (error) {
      let err = error as BusinessError;
      TCLogger.error('Camera', `recognizeImage failed. code=${err.code}, message=${err.message}`);
      return ''
    }
  }
}