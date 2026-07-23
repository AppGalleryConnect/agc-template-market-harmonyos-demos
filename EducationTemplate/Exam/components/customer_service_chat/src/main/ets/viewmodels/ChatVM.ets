import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { sceneMap } from '@kit.MapKit';
import { PickerController } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { ChatMockService } from '../mocks/ChatMockService';
import { LocationInfo, MessageModel, MessageType, SenderType } from '../models/MessageModel';
import { SpeechRecognizer } from '../models/SpeechRecognizer';
import { WindowModel } from '../models/WindowModel';
import { ChatUtil } from '../utils/ChatUtil';
import {
  chooseLocation,
  displayLocation,
  pickPhoto,
  requestPermissionsFromUser,
  takePhoto
} from '../utils/SystemUtils';
import { FileUtils } from '../utils/FileUtil';

@ObservedV2
export class ChatVM {
  private static _instance: ChatVM | null;
  @Trace breakpoint: string = 'sm';
  @Trace messageList: MessageModel[] = [];
  @Trace isRefreshing: boolean = false;
  // 是否语音模式
  @Trace isVoiceMode: boolean = false;
  // 输入内容
  @Trace textValue: string = '';
  // 是否展开
  @Trace isExpand: boolean = false;
  // 是否有麦克风权限
  @Trace isMicroPermission: boolean = false;
  // 文本框控制器
  @Trace textAreaController: TextAreaController = new TextAreaController();
  @Trace windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Trace keyboardPadding: number = 0;
  @Trace isKeyboard: boolean = false;
  @Trace locationWidth: number = 0;
  @Trace containerWidth: number = 0;
  // 临时识别结果
  private tempSpeechText: string = '';
  speechRecognizer: SpeechRecognizer = new SpeechRecognizer();
  maxSelectNumber: number = 5;
  scrollController: Scroller = new Scroller();
  pickerController: PickerController = new PickerController();
  currentService: ChatMockService = new ChatMockService();

  public static getInstance(reCreate: boolean = false) {
    if (!ChatVM._instance || reCreate) {
      ChatVM._instance = new ChatVM();
    }
    return ChatVM._instance;
  }

  // 滚动到底部
  scrollToBottom() {
    setTimeout(() => {
      this.scrollController.scrollEdge(Edge.Bottom);
    }, 100);
  }

  // 初始化服务
  async initializeService() {
    if (!this.messageList.length) {
      // 注册回调，注册过则忽略
      this.currentService.onMessageReceived((message: MessageModel) => {
        this.messageList.push(message);
      });
    }

    // 清除之前
    this.messageList = [];
    this.currentService.disconnect();

    // 连接服务
    await this.loadHistoryMessage();
    this.scrollToBottom();
    this.currentService.connect().then(() => {
      this.scrollToBottom();
    });

  }

  async loadHistoryMessage() {
    this.currentService.queryHistoryMessage().then((list) => {
      this.messageList = list;
      this.isRefreshing = false;
    })
  }

  onCameraIconClick = async (context: common.UIAbilityContext) => {
    const result = await takePhoto(context);
    if (result.resultCode === 0) {
      this.sendImageMessage(result.resultUri, true);
    }
  }
  onPictureIconClick = async (context: common.UIAbilityContext) => {
    const imageUris: string[] = await pickPhoto(this.maxSelectNumber);
    if (imageUris.length) {
      imageUris.forEach((uri) => {
        const cacheUri = FileUtils.copyImg2Sandbox(uri, context);
        this.sendImageMessage(cacheUri, false);
      })
    }
  }
  onLocationIconClick = async (context: common.UIAbilityContext) => {
    chooseLocation(context).then((result: sceneMap.LocationChoosingResult) => {
      this.sendLocationMessage(result);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'onLocationIconClick', '%{public}s', 'choose location err = ' + JSON.stringify(err));
    })
  }
  onVoiceIconClick = async (context: common.UIAbilityContext) => {
    this.isMicroPermission = await requestPermissionsFromUser('Micro', context);
    this.isVoiceMode = !this.isVoiceMode;
    this.isExpand = false;
    this.textAreaController.stopEditing();
    this.scrollToBottom();
  }

  onPlusIconClick() {
    this.isExpand = !this.isExpand;
    this.isVoiceMode = false;
    this.textAreaController.stopEditing();
    this.scrollToBottom();
  }

  async handleSpeaking(uiContext: UIContext) {
    if (this.isMicroPermission) {
      this.startSpeechRecognizer();
    } else {
      uiContext.getPromptAction().showToast({ message: $r('app.string.no_microphone_permission') })
    }
  }

  finishSpeaking() {
    this.speechRecognizer.stop();
  }

  startSpeechRecognizer() {
    this.speechRecognizer.start((result) => {
      const tempText: string = result.result;
      this.textValue = this.textValue.replace(this.tempSpeechText, '');
      this.textValue += tempText;
      this.tempSpeechText = result.isFinal ? '' : tempText;
    })
  }

  // 发送图片消息
  sendImageMessage(uri: string, isCamera: boolean) {
    const userMessage: MessageModel = {
      id: Date.now().toString(),
      content: uri,
      type: MessageType.IMAGE,
      timestamp: Date.now(),
      isShowTime: false,
      sender: SenderType.USER,
    }
    const imageSource = image.createImageSource(uri);
    let aspectRatio = 1;
    if (!isCamera) {
      imageSource.getImageInfo((error: BusinessError, imageInfo: image.ImageInfo) => {
        if (error) {
          hilog.error(0x0000, 'sendImageMessage', `getImageInfo failed, error: ${error.code}, ${error.message}`);
        } else {
          hilog.info(0x0000, 'sendImageMessage', 'getImageInfo succeed, info: ' + JSON.stringify(imageInfo));
          aspectRatio = imageInfo.size.width / imageInfo.size.height;
        }
        userMessage.imageAspectRatio = aspectRatio;
        userMessage.isShowTime = ChatUtil.setDisplayTime(userMessage, this.messageList);
        this.processOfSendMessage(userMessage);
      });
    } else {
      userMessage.imageAspectRatio = aspectRatio;
      userMessage.isShowTime = ChatUtil.setDisplayTime(userMessage, this.messageList);
      this.processOfSendMessage(userMessage);
    }
  }

  // 发送位置消息
  sendLocationMessage(site: sceneMap.LocationChoosingResult) {
    const userMessage: MessageModel = {
      id: Date.now().toString(),
      type: MessageType.LOCATION,
      content: '',
      timestamp: Date.now(),
      isShowTime: false,
      sender: SenderType.USER,
      locationInfo: {
        siteId: site.siteId,
        address: site.address,
        addressComponent: site.addressComponent,
        name: site.name,
        locationSnapShot: site.snapshot,
        locationLongitude: site.location.longitude,
        locationLatitude: site.location.latitude,
      },
    }
    userMessage.isShowTime = ChatUtil.setDisplayTime(userMessage, this.messageList);
    this.processOfSendMessage(userMessage);
  }

  // 发送文本消息
  sendTextMessage() {
    if (this.textValue.trim() === '') {
      return;
    }

    const userMessage: MessageModel = {
      id: Date.now().toString(),
      content: this.textValue,
      type: MessageType.TEXT,
      timestamp: Date.now(),
      isShowTime: false,
      sender: SenderType.USER,
    }
    userMessage.isShowTime = ChatUtil.setDisplayTime(userMessage, this.messageList);
    this.processOfSendMessage(userMessage);
    // 清空输入框
    this.textValue = '';
  }

  processOfSendMessage(userMessage: MessageModel) {
    // 先添加到列表（乐观更新）
    this.messageList.push(userMessage);
    this.scrollToBottom();
    this.currentService.sendMessage(userMessage).then(() => {
      this.scrollToBottom();
    });
  }

  // 点击位置消息
  async onLocationClick(locationInfo: LocationInfo, context: Context) {
    await displayLocation(locationInfo, context);
  }

  // 点击图片消息
  onImageClick(uiContext: UIContext, image: ResourceStr) {
    const resources = [
      new SourceImageModel({
        imageUrl: image,
      }),
    ];

    const options: ImagePreviewOptions = new ImagePreviewOptions();
    options
      .setImageList(resources)
      .setInitIndex(0)
      .setShowPageText(false)

    ImagePreview.open(uiContext, options);
  }

  // 点击链接消息
  onUrlClick(context: common.UIAbilityContext, url: string) {
    ChatUtil.openUrlToWeb(context, url);
  }

  onKeyBoardCB: (height: number) => void = (height: number) => {
    this.isKeyboard = height > 0;
    if (this.isKeyboard) {
      this.scrollToBottom();
    }
    this.keyboardPadding = height;
  };

  closeAll() {
    this.textAreaController.stopEditing();
    this.isVoiceMode = false;
    this.isExpand = false;
  }

  calculateWidth() {
    const columnWidth = (this.containerWidth -
      GridRowColSetting.getGutter(this.breakpoint) * (GridRowColSetting.getWindowColumn(this.breakpoint) - 1)) /
    GridRowColSetting.getWindowColumn(this.breakpoint);
    this.locationWidth = 4 * columnWidth + 3 * GridRowColSetting.getGutter(this.breakpoint)
  }
}