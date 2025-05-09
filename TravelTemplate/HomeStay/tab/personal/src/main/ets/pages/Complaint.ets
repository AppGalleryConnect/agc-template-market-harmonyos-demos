import { Constants } from 'constant';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AddComplaintsRequest, https } from 'network';
import { requestAndUploadPic } from 'util';
import { TitleBar } from 'component';

@Builder
export function ComplaintBuilder() {
  Complaint();
}

@Component
export struct Complaint {
  @State isSelected: boolean = false;
  @State text: string = '';
  @State localImgUri: string = '';
  @State phoneNo: string = '';
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  controller: TextInputController = new TextInputController();

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '投诉建议', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        Column() {
          Column() {
            Text() {
              Span('投诉建议').fontSize(14).opacity(0.4).fontColor(Color.Black);
              Span('*').fontSize(18).fontColor(Color.Red);
            }.margin({ bottom: 12 });

            TextArea({ text: this.text, placeholder: '请填写10个字以上的问题描述以便我们提供更好的帮助' })
              .placeholderFont({ size: $r('sys.float.Body_S') })
              .height(180)
              .border({ width: 1, color: '#DDDDDD', radius: 8 })
              .backgroundColor(Color.White)
              .align(Alignment.Top)
              .wordBreak(WordBreak.BREAK_ALL)
              .onChange((value: string) => {
                this.text = value;
              });
          }.alignItems(HorizontalAlign.Start).padding(16);

          Column() {
            Text('图片').fontSize(14).margin({ bottom: 12 }).opacity(0.4).fontColor(Color.Black);

            Stack({ alignContent: Alignment.TopEnd }) {
              Image(this.isSelected ? this.localImgUri : $r('app.media.pic_add'))
                .size({ width: 80, height: 80 })
                .objectFit(ImageFit.Contain)
                .onClick(async () => {
                  const result = await requestAndUploadPic(getContext(this) as common.UIAbilityContext);
                  if (result && result?.photoUris.length !== 0) {
                    this.isSelected = true;
                    this.localImgUri = result.photoUris[0];
                  }
                }).padding(4);

              if (this.localImgUri.length !== 0) {
                Image($r('app.media.clear')).size({ width: 16, height: 16 }).onClick(() => {
                  this.isSelected = false;
                  this.localImgUri = '';
                });
              }
            };
          }.alignItems(HorizontalAlign.Start).padding(16).width(Constants.FULL_SCREEN);

          Column() {
            Text('联系电话').fontSize(14).margin({ bottom: 12 }).opacity(0.4).fontColor(Color.Black);

            TextInput({ placeholder: '选填 便于我们与您联系', text: this.phoneNo, controller: this.controller })
              .placeholderFont({ size: 12 })
              .border({ width: 1, color: '#DDDDDD', radius: 8 })
              .backgroundColor(Color.White)
              .onChange((value: string) => {
                this.phoneNo = value;
              });
          }.alignItems(HorizontalAlign.Start).padding(16);

          Blank();

          Row() {
            Button('提交', { type: ButtonType.Normal })
              .width(Constants.FULL_SCREEN)
              .borderRadius($r('sys.float.corner_radius_level4'))
              .backgroundColor('#007DFF')
              .onClick(() => {
                this.submit();
              });
          }.justifyContent(FlexAlign.Center).padding({ left: 16, right: 16 }).margin({ bottom: 16 });
        }.height('90%');
      };
    }.hideTitleBar(true);
  }

  async submit() {
    if (this.text.length === 0) {
      promptAction.showToast({
        message: '请填写投诉建议内容',
        duration: 2000,
      });
      return;
    }

    const data: AddComplaintsRequest = {
      openId: '',
      phone: this.phoneNo,
      content: this.text,
      appId: '',
      filePath: this.localImgUri,
    };

    const res = await https.addComplaints(data);
    if (res.code === 200) {
      promptAction.showToast({
        message: '提交成功',
        duration: 1000,
      });
      this.mainPathStack.pop();
    }
  }
}