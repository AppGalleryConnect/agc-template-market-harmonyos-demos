import { common } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { textRecognition } from '@kit.CoreVisionKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { PermissionUtil } from './PermissionUtil';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { AudioCapturerUtil } from './AudioCapturerUtil';
import { SpeechRecognizeUtil } from './SpeechRecognizeUtil';
import { SpeechRecordDialogUtil, SpeechRecordParam } from '../components/SpeechRecordDialog';

const TAG = '[AddressRecognitionUtil]'

export class AddressRecognitionUtil {
  public static imageSource: image.ImageSource | undefined = undefined;
  public static chooseImage: PixelMap | undefined = undefined;
  public static audioCapture: AudioCapturerUtil = new AudioCapturerUtil();
  public static speechRecognize: SpeechRecognizeUtil = new SpeechRecognizeUtil();
  public static audioFileName: string = '';

  // 拍照识别
  public static async takePhoto(context: common.UIAbilityContext, loadingCB: () => void): Promise<string> {
    let recognizeText = '';
    if (context) {
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(context,
        [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO], pickerProfile);
      if (pickerResult.resultCode === 0) {
        loadingCB();
        // 加载图片
        await AddressRecognitionUtil.loadImage(pickerResult.resultUri);
        // 开始识别
        recognizeText = await AddressRecognitionUtil.recognizeImageToText();
      }
    }
    return recognizeText;
  }

  // 从相册选择图片识别
  public static async imagePicker(): Promise<string> {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    // 过滤选择媒体文件类型为IMAGE
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    // 选择媒体文件的最大数目
    photoSelectOptions.maxSelectNumber = 1;
    let photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    let recognizeText = '';
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoViewPicker.select(photoSelectOptions);
    let uris = photoSelectResult?.photoUris;
    if (uris?.length > 0) {
      // 加载图片
      await AddressRecognitionUtil.loadImage(uris[0]);
      // 开始识别
      recognizeText = await AddressRecognitionUtil.recognizeImageToText();
    }
    return recognizeText;
  }

  // 加载指定路径的图片
  public static async loadImage(name: string) {
    let fileSource = await fileIo.open(name, fileIo.OpenMode.READ_ONLY);
    AddressRecognitionUtil.imageSource = image.createImageSource(fileSource.fd);
    AddressRecognitionUtil.chooseImage = await AddressRecognitionUtil.imageSource.createPixelMap();
  }

  // 识别图片
  public static async recognizeImageToText(): Promise<string> {
    if (!AddressRecognitionUtil.chooseImage) {
      UtilLog.error(TAG, 'Failed to recognize: no image information detected.')
      return '';
    }
    // 调用文本识别接口
    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: AddressRecognitionUtil.chooseImage
    };
    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    };
    let recognizeText = '';
    try {
      let recognitionResult = await textRecognition.recognizeText(visionInfo, textConfiguration);
      if (recognitionResult?.value) {
        recognizeText = recognitionResult.value;
      }
    } catch (e) {
      UtilLog.error(TAG, `Failed to recognize, error: ${JSON.stringify(e)}`)
    }

    return recognizeText;
  }

  // 开始语音识别
  public static async speechRecognition(
    uiContext: UIContext,
    onResultCallback: (text: string) => void,
    onCompleteCallback: () => void,
    confirm: () => void,
  ) {
    // 录音权限
    const context = uiContext.getHostContext() as common.UIAbilityContext
    PermissionUtil.setContext(context);
    const hasMicPermission = await PermissionUtil.requestPermissions(['ohos.permission.MICROPHONE']);
    if (!hasMicPermission) {
      ToastDialog.showToast({ message: '录音功能需要先开启麦克风权限！'});
      return;
    }
    // 打开录音弹框
    let speechRecordDialogUtil = new SpeechRecordDialogUtil(uiContext);
    const param = {
      confirm: () => {
        speechRecordDialogUtil.close();
        AddressRecognitionUtil.stopRecorder(context);
        confirm();
      },
      cancel: () => {
        // 关闭弹框
        speechRecordDialogUtil.close();
        // 释放录音对象
        AddressRecognitionUtil.audioCapture.stopAndRelease();
        // 删除沙箱的录音文件
        let path = context.cacheDir;
        let filePath = path + `/${AddressRecognitionUtil.audioFileName}.pcm`;
        AddressRecognitionUtil.speechRecognize.deleteAudio(filePath);
      }
    } as SpeechRecordParam
    await speechRecordDialogUtil.open(param);
    // 录音
    AddressRecognitionUtil.audioFileName = Date.now().toString();
    AddressRecognitionUtil.audioCapture.createAudio(AddressRecognitionUtil.audioFileName, context);
    // 语音识别设置创建引擎参数以及监听
    if (!AddressRecognitionUtil.speechRecognize.asrEngine) {
      AddressRecognitionUtil.speechRecognize.setResultCallback(onResultCallback)
      AddressRecognitionUtil.speechRecognize.setCompleteCallback(onCompleteCallback)
      AddressRecognitionUtil.speechRecognize.createSpeechEngine();
    }
  }

  // 录音结束
  public static async stopRecorder(context: common.UIAbilityContext) {
    await AddressRecognitionUtil.audioCapture.stopAndRelease();

    const sessionId = Date.now().toString();
    AddressRecognitionUtil.speechRecognize.writeAudio(sessionId, AddressRecognitionUtil.audioFileName, context);
  }
}