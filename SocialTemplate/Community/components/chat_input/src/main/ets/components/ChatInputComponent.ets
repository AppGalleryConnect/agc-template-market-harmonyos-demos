/**
 * @usage: 即时通讯场景的聊天输入组件，支持文本输入、长按语音识别、表情选择、照片/视频选择以及位置选择。
 * 关键数据结构：ChatInputSendMessageModel（封装消息内容与元数据），MoreTypeItem（更多类型项）。
 * 关键枚举：ChatTypeEnum（消息类型）、InputShowMode（展示模式：DEFAULT/EMOJI/FILE）。
 * 包含 if 逻辑：isVoiceMode 控制文本输入与语音长按切换，showMode 控制 Tabs 显示页（表情/文件）。
 * @layout: 纵向布局（RelativeContainer）：
 * 顶部为输入行 Row（水平居中，左右对齐）：
 *  - 左侧为语音/键盘切换图标（Image），点击切换 isVoiceMode；
 *  - 中间为 Stack（居中对齐，圆角背景），包含 TextInput 与“按住说话”文本二选一（根据 isVoiceMode 切换显示）；
 *  - 右侧为表情按钮与更多按钮（Image），依次切换 showMode=EMOJI/FILE；
 * 底部为 Tabs（两页）：
 *  - 第 1 页为表情选择（emojiBuilder），展示固定表情列表；
 *  - 第 2 页为文件选择（fileSelectBuilder），可选照片/拍照/位置。
 * Tabs 通过 alignRules 固定于容器底部，随 showMode 控制可见性，高度固定 98；整体宽度 100%。
 * @constraints: 组件样式固定，文案固定，语音、文件选择样式固定
 * @isGen: false
 * @fileType: component
 * @domain: 社交交友
 * @zhName: 聊天输入组件
 * @subPage: VoiceView
 * @component:
 * @image: screenshot/chatinput.png
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { cameraPicker as picker } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import { sceneMap } from '@kit.MapKit';
import { ChatBreakpoint, ChatBreakpointEnum, ChatTypeEnum } from 'chat_base';
import { ChatInputComponentViewModel, InputShowMode } from '../viewmodel/ChatInputComponentViewModel';
import { MoreTypeItem } from '../model/MoreTypeItem';
import { ChatInputSendMessageModel } from '../model/ChatInputSendMessageModel';
import { VoiceView } from './VoiceView';
import { ChooseLocationUtil } from 'chat_location';
import { INPUT_EXPRESSION_LIST } from '../constants/Constants';
import { requestPermission } from '../utils/RequestPermission'

@ComponentV2
export struct ChatInputComponent {
  // 外部输入
  @Once @Param initialContent: string = '';
  @Event sendMessageAction: (content: ChatInputSendMessageModel) => void =
    (_content: ChatInputSendMessageModel) => {
    }
  // 本地使用
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local emojiPositionY: number = 40
  private textInputController: TextInputController = new TextInputController()
  private vm: ChatInputComponentViewModel = new ChatInputComponentViewModel()
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  private dataPreferences: preferences.Preferences | undefined = undefined;

  @Computed
  get emojiColumns(): number {
    if (this.chatBreakpoint.currentChatBreakpoint === ChatBreakpointEnum.SM ||
      this.chatBreakpoint.currentChatBreakpoint === ChatBreakpointEnum.MD) {
      return 8
    }

    return 12
  }

  aboutToAppear(): void {
    this.vm.initEngine(this.initialContent)
    this.dataPreferences = preferences.getPreferencesSync(this.context, { name: 'chatInput' })
  }

  aboutToDisappear(): void {
    this.vm.speechRecognizer.shutdown()
  }

  // 开始识别
  public startSpeechRecognizer() {
    this.vm.startSpeechRecognizer(this.context, (size: number, duration: number) => {
      const msgModel: ChatInputSendMessageModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_SOUND)
      msgModel.duration = duration
      msgModel.size = size
      msgModel.audioUrl = this.vm.audioPath
      msgModel.content = this.vm.audioText
      this.sendMessageAction(msgModel)
    })
  }

  // 停止识别
  public stopSpeechRecognizer() {
    this.vm.isLongPressing = false
    if (this.vm.dialodId === -1) {
      return
    }

    hilog.info(0x0000, 'ChatInputComponent', '%{public}s', 'stopSpeechRecognizer')
    this.getUIContext().getPromptAction().closeCustomDialog(this.vm.dialodId)
    this.vm.speechRecognizer.stop();
    this.vm.dialodId = -1
  }

  build() {
    RelativeContainer() {
      this.inputRowBuilder()

      this.tabsBuilder()
    }
    .height(55 + this.chatBreakpoint.bottomValue + (this.vm.showMode !== InputShowMode.DEFAULT ? 98 : 0))
    .width('100%')
    .backgroundColor(Color.White)
    .padding({
      left: this.chatBreakpoint.pagePadding,
      right: this.chatBreakpoint.pagePadding,
      bottom: this.chatBreakpoint.bottomValue
    })
  }

  @Builder
  inputRowBuilder() {
    Row() {
      Image(!this.vm.isVoiceMode ? $r('app.media.voice_icon') : $r('app.media.keyboard_icon'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .margin({ right: 8 })
        .onClick(() => {
          this.vm.isVoiceMode = !this.vm.isVoiceMode
          if (this.vm.isVoiceMode) {
            // 关闭键盘
            this.textInputController.stopEditing()
          } else {
            this.vm.editContent = ''
          }
        })

      Stack({ alignContent: Alignment.Center }) {
        this.textInputBuilder()

        this.pressSayBuilder()
      }
      .layoutWeight(1)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('sys.color.mask_sixth'))

      Image($r('app.media.emoji_icon'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .margin({ left: 8 })
        .onClick(() => {
          if (this.vm.showMode === InputShowMode.EMOJI) {
            this.vm.showMode = InputShowMode.DEFAULT
            return
          }

          this.vm.showMode = InputShowMode.EMOJI
          this.vm.currentTabIndex = 0
          this.textInputController.stopEditing()
        })

      Image($r('app.media.more_icon'))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .margin({ left: 8 })
        .onClick(() => {
          if (this.vm.showMode === InputShowMode.FILE) {
            this.vm.showMode = InputShowMode.DEFAULT
            return
          }

          this.vm.showMode = InputShowMode.FILE
          this.vm.currentTabIndex = 1
          this.textInputController.stopEditing()
        })
    }
    .height(55)
    .alignItems(VerticalAlign.Center)
    .alignRules({
      top: { anchor: '__container__', align: VerticalAlign.Top },
      right: { anchor: '__container__', align: HorizontalAlign.End },
      left: { anchor: '__container__', align: HorizontalAlign.Start }
    })
  }

  @Builder
  textInputBuilder() {
    TextInput({ placeholder: '', text: this.vm.editContent, controller: this.textInputController })
      .width('100%')
      .height('100%')
      .fontSize(14)
      .fontColor(Color.Black)
      .backgroundColor(Color.Transparent)
      .enterKeyType(EnterKeyType.Send)
      .visibility(!this.vm.isVoiceMode ? Visibility.Visible : Visibility.None)
      .onChange((value: string) => {
        this.vm.editContent = value
      })
      .onEditChange((isEditing: boolean) => {
        if (isEditing && this.vm.showMode !== InputShowMode.DEFAULT) {
          this.vm.showMode = InputShowMode.DEFAULT
        }
      })
      .onSubmit((_enterKey: EnterKeyType, event: SubmitEvent) => {
        if (this.vm.editContent.length === 0) {
          // 无内容
          return
        }

        // 保持键盘不关闭
        event.keepEditableState()
        // 发送内容
        const sendContent: ChatInputSendMessageModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_TEXT)
        sendContent.content = this.vm.editContent
        this.sendMessageAction(sendContent)

        this.vm.editContent = ''
      })
  }

  @Builder
  pressSayBuilder() {
    Text($r('app.string.press_say'))
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .fontSize(14)
      .fontColor(Color.Black)
      .backgroundColor(Color.Transparent)
      .visibility(this.vm.isVoiceMode ? Visibility.Visible : Visibility.None)
      .gesture(LongPressGesture({ repeat: false })
        .onAction(() => {
          this.vm.isLongPressing = true
          requestPermission(this.context).then((suc) => {
            // 没权限
            if (!suc) {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.not_microphone_power')
              })
              return
            }

            // 手指已挪开
            if (!this.vm.isLongPressing) {
              return
            }

            // 首次会弹出隐私弹框抢占焦点
            const key: string = 'chatInputKey'
            if ((this.dataPreferences !== undefined) && !this.dataPreferences.hasSync(key)) {
              this.vm.isLongPressing = false
              this.dataPreferences.putSync(key, true)
              this.dataPreferences.flushSync()
              return
            }

            // 已授权
            this.startSpeechRecognizer()
            this.getUIContext().getPromptAction().openCustomDialog({
              builder: () => {
                this.voiceViewBuilder()
              },
              alignment: DialogAlignment.Bottom,
              showInSubWindow: true,
              maskColor: 'rgba(0, 0, 0, 0.5)',
              width: 296,
              height: 110,
              offset: { dx: 0, dy: -(90 + this.chatBreakpoint.bottomValue) },
              onDidAppear: () => {
                this.vm.timerId = setInterval(async () => {
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.voice_timeout'),
                  });
                  this.stopSpeechRecognizer();
                }, 20000);
              },
              onWillDisappear: () => {
                clearInterval(this.vm.timerId);
              }
            })
              .then((id) => {
                this.vm.dialodId = id
              })
          })
        })
        .onActionEnd(() => {
          this.stopSpeechRecognizer()
        })
        .onActionCancel(() => {
          this.stopSpeechRecognizer()
        }))
  }

  // 表情与文件
  @Builder
  tabsBuilder() {
    Tabs({ index: $$this.vm.currentTabIndex }) {
      TabContent() {
        this.emojiBuilder()
      }

      TabContent() {
        this.fileSelectBuilder()
      }
    }
    .clip(true)
    .barHeight(0)
    .animationDuration(0)
    .scrollable(false)
    .visibility((this.vm.showMode !== InputShowMode.DEFAULT) ? Visibility.Visible : Visibility.None)
    .height(98)
    .alignRules({
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
      right: { anchor: '__container__', align: HorizontalAlign.End },
      left: { anchor: '__container__', align: HorizontalAlign.Start }
    })
  }

  @Builder
  emojiBuilder() {
    RelativeContainer() {
      GridRow({
        columns: this.emojiColumns
      }) {
        ForEach(INPUT_EXPRESSION_LIST, (item: string) => {
          GridCol() {
            Column() {
              Text(item)
                .fontSize(20)
            }
            .width('100%')
            .aspectRatio(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.vm.isVoiceMode) {
                return
              }
              this.vm.editContent += item
            })
          }
        }, (item: string, index: number) => item + index)
      }
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        right: { anchor: '__container__', align: HorizontalAlign.End },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
        if (newValue.height !== undefined) {
          const height = newValue.height as number
          this.emojiPositionY = height * 0.5 + (height * 0.5 - 36) / 2
        }
      })

      Text($r('app.string.send'))
        .fontSize(14)
        .size({ width: 48, height: 36 })
        .fontColor(Color.White)
        .backgroundColor('#675CF8')
        .borderRadius(10)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End },
        })
        .margin({ top: this.emojiPositionY })
        .id('emojisend')
        .onClick(() => {
          if (this.vm.editContent.length === 0) {
            return
          }

          // 发送内容
          const sendContent: ChatInputSendMessageModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_TEXT)
          sendContent.content = this.vm.editContent
          this.sendMessageAction(sendContent)

          this.vm.editContent = ''
        })

      Image($r('app.media.emoji_delete'))
        .size({ width: 48, height: 36 })
        .objectFit(ImageFit.Cover)
        .padding({
          top: 4,
          bottom: 4,
          left: 12,
          right: 12
        })
        .backgroundColor('#F2F2F2')
        .borderRadius(10)
        .alignRules({
          top: { anchor: 'emojisend', align: VerticalAlign.Top },
          right: { anchor: 'emojisend', align: HorizontalAlign.Start },
        })
        .margin({ right: 10 })
        .onClick(() => {
          this.vm.deleteTextLastOne()
        })
    }
    .width('100%')
    .height('100%')

  }

  @Builder
  fileSelectBuilder() {
    Grid() {
      ForEach(this.vm.moreTypeItems, (item: MoreTypeItem, index: number) => {
        GridItem() {
          Column() {
            Image(item.source)
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)
              .margin({ bottom: 10 })

            Text(item.title)
              .fontSize(12)
              .fontColor(Color.Black)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .onClick(async () => {
          switch (index) {
            case 0: {
              // 选择文件
              this.vm.selectPhoto(this.context).then(async (result: string) => {
                // 发送内容
                const msgType: ChatTypeEnum = this.vm.getFileType(result)
                if (msgType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
                  const sendContent = await this.vm.getImageInfo(result)
                  this.sendMessageAction(sendContent)
                } else if (msgType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
                  const sendContent = await this.vm.getVideoInfo(this.getUIContext(), result)
                  sendContent && this.sendMessageAction(sendContent)
                }
              })
            }
              break
            case 1: {
              // 拍照
              let pathDir = this.context.cacheDir;
              let fileName = `${Date.now()}`;
              let filePath = pathDir + `/${fileName}.tmp`;
              let result = await this.vm.takePhoto(this.context, filePath)
              if (result.resultCode === 0) {
                if (result.mediaType === picker.PickerMediaType.PHOTO) {
                  const sendContent = await this.vm.getImageInfo(filePath)
                  this.sendMessageAction(sendContent)
                } else {
                  const sendContent = await this.vm.getVideoInfo(this.getUIContext(), filePath)
                  sendContent && this.sendMessageAction(sendContent)
                }
              }
            }
              break
            case 2: {
              //  位置
              ChooseLocationUtil.chooseLocation(this.context)
                .then((result: sceneMap.LocationChoosingResult) => {
                  hilog.info(0x0000, 'ChatInputComponent', '%{public}s',
                    'choose location result = ' + JSON.stringify(result));
                  this.sendMessageAction(this.vm.getLocationInfo(result));
                })
                .catch((err: BusinessError) => {
                  hilog.error(0x0000, 'ChatInputComponent', '%{public}s',
                    'choose location err = ' + JSON.stringify(err));
                  this.getUIContext().getPromptAction().showToast({ message: '选择位置失败' });
                })
            }
              break
            default:
              break
          }
        })
      }, (item: MoreTypeItem, index: number) => item.title + index)
    }
    .width('100%')
    .height('100%')
    .columnsGap(14)
    .columnsTemplate('1fr 1fr 1fr')
  }

  @Builder
  voiceViewBuilder() {
    VoiceView({ audioPath: this.vm.audioPath, audioRecorder: this.vm.audioRecorder })
  }
}
