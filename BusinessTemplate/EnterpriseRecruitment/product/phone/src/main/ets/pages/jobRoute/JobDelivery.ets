import { AppStorageV2, PersistenceV2, promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  AttachmentDatabase,
  AvoidArea,
  UserContactInfo,
  CommonConstants,
  DeliveryDatabase,
  DeliveryRecord,
  getCurrentLocalDate,
  JobListItem,
  LeftReturnComponent,
  Logger,
  MyDataSource,
  promptFun,
  ResumeEntity,
  SearchType,
  TitleBar
} from '@ohos_agcit/common_component';
import { picker } from '@kit.CoreFileKit';

const TAG: string = 'AttachUpload';
let addressList: SearchType[] = CommonConstants.ADDRESS_COLLECTION;
let addressMap: Map<number, SearchType> = new Map<number, SearchType>(
  addressList.map(item => [item.index, item])
);

@Entry
@ComponentV2
export struct JobDelivery {
  @Local jobInfo: JobListItem = router.getParams() as JobListItem;
  @Local name: string = '';
  @Local email: string = '';
  @Local telephoneNumber: string = '';
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local userContactInfo: UserContactInfo =
    PersistenceV2.connect(UserContactInfo, () => new UserContactInfo('', '', ''))!;
  @Local deliveryDatabase: DeliveryDatabase =
    PersistenceV2.connect(DeliveryDatabase, () => new DeliveryDatabase())!;
  @Local attachmentDatabase: AttachmentDatabase =
    PersistenceV2.connect(AttachmentDatabase, () => new AttachmentDatabase())!;
  @Local attachmentLazyList: MyDataSource<ResumeEntity> = new MyDataSource();
  @Local isHalfShow: boolean = false;
  @Local isFullShow: boolean = false;
  @Local resumeUri: string = '';
  @Local resumeName: string = '';
  @Local isDelivery: boolean = this.deliveryDatabase.deliveryList.some(record => record.jobId === this.jobInfo.jobId)

  aboutToAppear(): void {
    this.attachmentLazyList.clear()
    for (let i = 0; i < this.attachmentDatabase.attachmentList.length; i++) {
      this.attachmentLazyList.pushData(this.attachmentDatabase.attachmentList[i])
    }
  }

  build() {
    Column() {
      Column() {
        Row() {
          LeftReturnComponent()
            .onClick(() => {
              router.back();
            })
          TitleBar({ text: '简历投递' })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
      }
      .height('7%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        Text(this.jobInfo.jobName)
          .fontSize($r('app.float.font_size_18'))
          .fontColor(Color.Black)
          .fontWeight(CommonConstants.FONT_WEIGHT_600)
        Text(addressMap.get(this.jobInfo.address)?.title + ' · ' + this.jobInfo.jobType)
          .fontSize($r('app.float.font_size_16'))
          .fontColor($r('app.color.common_gray'))
          .margin({ top: '3%' })
      }
      .borderRadius(CommonConstants.COMMON_RADIUS)
      .backgroundColor(Color.White)
      .width('100%')
      .height('10%')
      .alignItems(HorizontalAlign.Start)
      .padding('5%')

      Text('应聘者信息')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.common_gray'))
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .alignSelf(ItemAlign.Start)
        .height('8%')
        .width('100%')
        // .margin({ top: '2%' })

      // message input
      Column() {
        this.MessageInput('姓名', ContentType.USER_NAME, this.userContactInfo.realName, (val: string) => {
          this.name = val;
          this.userContactInfo.realName = val
        })
        Divider().strokeWidth(1).color(Color.Gray).opacity(0.2).margin({ bottom: '2.5%' });

        this.MessageInput('手机号码', ContentType.PHONE_NUMBER, this.userContactInfo.phoneNumber, (val: string) => {
          this.telephoneNumber = val;
          this.userContactInfo.phoneNumber = val
        })
        Divider().strokeWidth(1).color(Color.Gray).opacity(0.2).margin({ bottom: '2.5%' });

        this.MessageInput('邮箱', ContentType.EMAIL_ADDRESS, this.userContactInfo.email, (val: string) => {
          this.email = val;
          this.userContactInfo.email = val
        })
        Divider().strokeWidth(1).color(Color.Gray).opacity(0.2);
      }
      .padding({top:'2%', bottom: '5%', left: '5%', right: '5%'})
      .borderRadius(CommonConstants.COMMON_RADIUS)
      .backgroundColor(Color.White)
      .width('100%')
      .height('25%')

      // resume
      Column() {
        Row() {
          Text() {
            Span('简历')
              .fontColor(Color.Black)
            Span('*')
              .fontColor(Color.Red)
          }
          .fontWeight(CommonConstants.FONT_WEIGHT_600)
          .fontSize($r('app.float.font_size_18'))

          Blank()

          Text($r('app.string.upload_attachment'))
            .fontColor($r('app.color.common_blue'))
            .fontSize($r('app.float.font_size_16'))
            .onClick(() => {
              this.isHalfShow = !this.isHalfShow
            })
        }
        .width('100%')

        if (this.resumeName !== '') {
          Text(this.resumeName)
            .fontColor($r('app.color.common_blue'))
            .fontSize($r('app.float.font_size_16'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .margin({ top: '2.5%' })
        }

        Text('文件大小不超过50M; 支持格式为pdf')
          .fontColor($r('app.color.common_gray'))
          .fontSize($r('app.float.font_size_13'))
          .opacity(0.6)
          .margin({ top: '3%' })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('10%')
      .borderRadius(CommonConstants.COMMON_RADIUS)
      .backgroundColor(Color.White)
      .margin({ top: '5%' })
      .padding('5%')

      Blank()

      Button(this.isDelivery ? '已投递' : '简历投递')
        .fontSize($r('app.float.font_size_17'))
        .backgroundColor($r('app.color.common_blue'))
        .width('100%')
        .height('6%')
        .onClick(() => {
          if (this.isDelivery) {
            promptFun('您已投递，请勿重复投递', 1000)
          } else {
            if (this.name === '' || this.telephoneNumber === '' || this.email === '' || this.resumeUri.length === 0) {
              promptFun('请填写个人信息以及上传简历附件', 1000)
            } else {
              let deliveryRecord: DeliveryRecord = new DeliveryRecord()
              deliveryRecord.jobId = this.jobInfo.jobId
              deliveryRecord.submitTime = getCurrentLocalDate()
              deliveryRecord.status = 0

              this.deliveryDatabase.deliveryList.push(deliveryRecord)
              this.isDelivery = this.deliveryDatabase.deliveryList.some(record => record.jobId === this.jobInfo.jobId)
              promptFun('投递简历成功', 1000)
            }
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_background'))
    .bindSheet($$this.isHalfShow, this.UploadHalfSheetBuilder(), {
      height: '20%',
    })
    .bindContentCover($$this.isFullShow, this.AttachmentFullSheetBuilder(), {})
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '6%',
      right: '6%'
    })
  }

  @Builder
  MessageInput(title: string,contentType:ContentType, content:string, invoke: (val: string) => void) {
    Row() {
      Text() {
        Span(title)
          .fontColor(Color.Black)
        Span('*')
          .fontColor(Color.Red)
      }
      .fontWeight(CommonConstants.FONT_WEIGHT_600)
      .fontSize($r('app.float.font_size_18'))
      .width('28%')
      .height('100%')

      Blank();

      Column() {
        TextInput({ placeholder: '请输入（必填）', text:content})
          .layoutWeight(1)
          .contentType(contentType)
          .backgroundColor(Color.Transparent)
          .fontSize($r('app.float.font_size_16'))
          .width('100%')
          .onChange((val: string) => {
            invoke(val)
            content = val
          })
          .onEditChange((isEditing: boolean) => {
            if (!isEditing) {
              if (title === '手机号码') {
                let isPhoneNumber = /^1[3-9]\d{9}$/.test(content);
                if (!isPhoneNumber) {
                  promptAction.showToast({ message: '手机号码不正确。' });
                }
              }
              if (title === '邮箱') {
                let isEmail =  /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$/.test(content);
                if (!isEmail) {
                  promptAction.showToast({ message: '邮箱格式不正确。' });
                }
              }
            }
          })
        ;
      }
      .width('66%');
    }
    .alignItems(VerticalAlign.Center)
    .height('30%')
    .width('100%')
  }

  @Builder
  UploadHalfSheetBuilder() {
    Column() {
      Row() {
        Button($r('app.string.upload_from_local'))
          .fontSize($r('app.float.font_size_20'))
          .height('40%')
          .width('60%')
          .fontColor($r('app.color.common_blue'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        this.isHalfShow = !this.isHalfShow
        try {
          let documentPicker = new picker.DocumentViewPicker(getContext());
          documentPicker
            .select({
              maxSelectNumber: 1,
              fileSuffixFilters: ['文档|.pdf'],
            })
            .then((documentSelectResult: Array<string>) => {
              console.info('DocumentViewPicker.select successfully, uri: ' + JSON.stringify(documentSelectResult));
              let uri: string = documentSelectResult[0];

              let fileArray = uri.split('/');
              let fileName = fileArray[fileArray.length - 1]
              this.resumeName = decodeURIComponent(fileName)
              this.resumeUri = uri
            })
            .catch((err: BusinessError) => {
              Logger.error(TAG, `'DocumentViewPicker.select failed with err: ${JSON.stringify(err)}`);
            });
        } catch (err) {
          Logger.error(TAG, `'DocumentViewPicker failed with err: ${JSON.stringify(err)}`);
        }
      })

      Row() {
        Button($r('app.string.upload_from_management'))
          .fontSize($r('app.float.font_size_20'))
          .height('40%')
          .width('60%')
          .fontColor($r('app.color.common_blue'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        this.isFullShow = !this.isFullShow
        this.isHalfShow = !this.isHalfShow
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  AttachmentFullSheetBuilder() {
    Column() {
      Column() {
        Row() {
          LeftReturnComponent()
            .onClick(() => {
              this.isFullShow = !this.isFullShow
            })
          TitleBar({ text: '简历管理' })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
      }
      .padding({
        top: px2vp(this.avoidArea.topRectHeight) + 10,
        left: '6%',
        right: '6%'
      })
      .height('10%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        LazyForEach(this.attachmentLazyList, (item: ResumeEntity, index: number) => {
          Row() {
            Image($r('app.media.ic_resume'))
              .height(70)
              .width(70)

            Column() {
              Text(item.name + item.suffix)
                .fontWeight(FontWeight.Medium)
                .width('70%')
              Row() {
                Text(item.size)
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.common_gray_light'))
                Text('  ')
                Text('更新于')
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.common_gray_light'))
                Text(item.updateTime)
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.common_gray_light'))
              }
              .margin({ top: 5 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .height('100%')
          }
          .height(80)
          .borderRadius(20)
          .backgroundColor(Color.White)
          .margin({ top: '3.5%' })
          .onClick(() => {
            this.resumeUri = item.uri
            this.resumeName = decodeURIComponent(item.name + item.suffix)
            this.isFullShow = !this.isFullShow
          })
        })
      }
      .height('40%')
      .width('100%')
      .padding({ top: '5%' })
    }
    .backgroundColor($r('app.color.common_background'))
    .justifyContent(FlexAlign.Start)
    .height('100%')
    .width('100%')
  }
}