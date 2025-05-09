import { PreferenceModel, PreferencesUtil, RouterMap, RouterModule } from 'commonlib';
import { MainPageVM } from '../viewModels/MainPageVM';
import { SetFontSizeUtil } from '../utils/SetFontSizeUtil';


class NewsData{
  title:string=''
  content:string=''
  image?: Resource
  good:boolean=false
  collect:boolean=false
  share:number=0
}

@Builder
export function mySettingsBuilder() {
  MySettings();
}

// @Entry
@ComponentV2
export struct MySettings {
  vm: MainPageVM = MainPageVM.instance;
  @Local message: string = 'Hello World';
  @Local time: string = '2小时前'
  @Local newsData: NewsData = new NewsData();
  private initSize: number = 14;

  async aboutToAppear() {
    PreferencesUtil.getChangeFontSize().then((value:number) => {
      this.vm.changeFontSize = value;
      let setZSize: number = this.initSize + value;
      this.vm.fontSizeText = SetFontSizeUtil.getTextByFontSize(setZSize);
    });
  }

  @Builder
  Title() {
    Row() {
      Row() {
        Image($r('app.media.chevron_backward')).width(9).height(16)
          .margin({ left: 30, top: 48, bottom: 18})
          .onClick(() => {
          })
      }.justifyContent(FlexAlign.Start)
      .width('10%')
    }
    .width('100%')
    .backgroundColor('#E84026')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }


  build() {
    NavDestination(){
      Column() {
        Column() {
          Row() {
            Row() {
              Text('字号设置')
                .fontSize(`${ 16 + this.vm.changeFontSize }`)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight('medium ')
                .fontFamily('鸿蒙黑体')
                .margin({ left: 12 })
            }

            Row() {
              Text(this.vm.fontSizeText)
                .fontSize(`${ 14 + this.vm.changeFontSize }`)
              Image($r('app.media.right_arrow')).width(16).height(16)
            }
          }
          .width('100%')
          .height(46)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.SET_FONT_SIZE, param: null });
          })
          Divider().margin({ left: 12, top: 12, bottom: 12 })

          Row() {
            Row() {
              Text('隐私协议')
                .fontSize(`${ 16 + this.vm.changeFontSize }`)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight('medium ')
                .fontFamily('鸿蒙黑体')
                .margin({ left: 12 })
            }

            Image($r('app.media.right_arrow')).width(16).height(16)
          }
          .width('100%')
          .height(46)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.MINE_PRIVACY_POLICY, param: null })
          })
          Divider().margin({ left: 12, top: 12, bottom: 12 })
        }
        .padding(12)
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius(16)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .title('设置')
    .onShown(()=>{
      PreferencesUtil.getChangeFontSize().then((value) => {
        this.vm.changeFontSize = value;
      });
    })
  }
}
