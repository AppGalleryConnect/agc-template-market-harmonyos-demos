import {
  AttachmentDatabase,
  AvoidArea,
  CommonConstants,
  getCurrentLocalTime,
  LeftReturnComponent,
  MyDataSource,
  ResumeComponent,
  ResumeEntity,
  TitleBar
} from '@ohos_agcit/common_component';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, PersistenceV2, promptAction, router } from '@kit.ArkUI';


@Entry
@ComponentV2
export struct ResumeManagement {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local attachmentDatabase: AttachmentDatabase =
    PersistenceV2.connect(AttachmentDatabase, () => new AttachmentDatabase())!;
  @Local resumeData: MyDataSource<ResumeEntity> = new MyDataSource();

  aboutToAppear(): void {
    this.resumeData.clear()
    for (let i = 0; i < this.attachmentDatabase.attachmentList.length; i++) {
      this.resumeData.pushData(this.attachmentDatabase.attachmentList[i])
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
        LazyForEach(this.resumeData, (item: ResumeEntity, index: number) => {
          ResumeComponent({
            resume: item,
            remove: () => {
              let index = this.getIndexByUri(this.resumeData.getDataArray(), item.uri);
              this.attachmentDatabase.attachmentList.splice(index, 1)
              this.resumeData.deleteOneData(index)
            }
          })
            .margin({ top: 15 })
            .height(80)
            .width('100%')
        })
      }
      .justifyContent(FlexAlign.Start)
      .padding({ top: '5%', left: '6%', right: '6%' })
      .width('100%')


      Column() {
        Text($r('app.string.resume_management_notify'))
          .fontSize($r('app.float.font_size_13'))
          .fontColor($r('app.color.common_gray'))
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)
      .height('10%')
      .width('100%')
      .padding({ top: '5%', left: '6%' })

      Blank()

      Button('上传简历')
        .width('80%')
        .margin({ bottom: 30 })
        .backgroundColor($r('app.color.common_blue'))
        .onClick(() => {
          if (this.resumeData.totalCount() >= 3) {
            promptAction.showToast({ message: $r('app.string.resume_management_notify') });
            return;
          }

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
                let suffix = '.' + fileName.split('.')[fileName.split('.').length - 1]

                // 从公共目录拷贝到沙箱
                let srcFile: fs.File = null!;
                let dstFile: fs.File = null!;
                try {
                  srcFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
                  let timestamp = getCurrentLocalTime()
                  let dstPath =
                    getContext(this).filesDir + '/' + encodeURIComponent(timestamp.replace(/\D/g, '') + suffix);

                  // 先创建有读写权限的文件，再把不可读写的文件复制过来
                  dstFile = fs.openSync(dstPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

                  fs.copyFileSync(srcFile.fd, dstPath);

                  let stat = fs.statSync(dstPath);


                  let name = decodeURIComponent(fileName.split(suffix)[0])

                  let newResume: ResumeEntity = new ResumeEntity()
                  newResume.name = name
                  newResume.suffix = suffix
                  newResume.uri = dstPath
                  newResume.size = bytesToKb(stat.size) + 'KB'
                  newResume.updateTime = timestamp

                  this.attachmentDatabase.attachmentList.push(newResume)
                  this.resumeData.pushData(newResume)
                  console.log('Copy File success, dstPath=' + dstPath + ', dstFile.df=' + dstFile.fd);
                } catch (e) {
                  console.error('copy error')
                } finally {
                  fs.close(srcFile.fd)
                }
                console.log('Upload To Server');

              }).catch((err: BusinessError) => {
              console.error('DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
            });
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            console.error('DocumentViewPicker failed with err: ' + JSON.stringify(err));
          }
        })

    }
    .backgroundColor($r('app.color.common_background'))
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      bottom: px2vp(this.avoidArea.bottomRectHeight)
    })
  }

  private getIndexByUri(resumeList: Array<ResumeEntity>, uri: string): number {
    // 遍历任务列表
    for (let i = 0; i < resumeList.length; i++) {
      // 如果任务id相等
      if (resumeList[i].uri === uri) {
        // 返回索引
        return i
      }
    }
    // 如果没有找到，返回-1
    return -1
  }
}

function bytesToKb(bytes: number, decimalPlaces: number = 2): number {
  return parseFloat((bytes / 1024).toFixed(decimalPlaces));
}

