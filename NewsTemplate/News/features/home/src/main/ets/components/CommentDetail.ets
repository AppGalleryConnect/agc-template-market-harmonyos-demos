import { HomePageVM } from '../viewModels/HomePageVM';
import { mediaquery, promptAction, window } from '@kit.ArkUI';

const NEWS_TIME_MAX_LINES: number = 1;

class NewsData{
  title:string=''
  content:string=''
  image?: Resource
  comment:string=''
  good:boolean=false
  collect:boolean=false
  share:number=0
}



@Builder
export function commentDetailBuilder() {
  CommentDetail();
}

@ComponentV2
export struct CommentDetail {
  vm: HomePageVM = HomePageVM.instance;
  @Local isShowSheet: boolean = false;
  @Local customHeight: number = 300;
  @Local heartFlag: boolean = false;
  @Local collectFlag: boolean = false;
  @Local comment: string = '';
  @Local firstComment: string = ''
  @Local isStateEffect: boolean = false
  @Local num: number = 0.4
  @Local newsData: NewsData = new NewsData();
  @Local counts: number = 0;
  @Local likeFlag: boolean = false;
  textAreaController: TextAreaController = new TextAreaController();

  aboutToAppear(): void {

  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext(this)).then((windowClass)=>{
      windowClass.setPreferredOrientation(window.Orientation.PORTRAIT)
    })
  }

  @Builder
  AllComment() {
    List() {
      ListItem() {
        Column() {
          Row() {
            Image($r('app.media.ic_person'))
              .width(20)
              .height(20)
              .borderRadius('24vp')
                Text(this.vm.userInfo.name || '网友7890')
                  .fontSize(`${12 + this.vm.changeFontSize}`)
                  .margin({left:8})
                  .textAlign(TextAlign.Start)
                  .height(20)
                  .fontColor('#99000000')
          }
          .width('100%')
          Row() {
              Text(`${this.vm.comment||'真是一个好消息～哈哈哈～'}`)
                .fontSize(`${14 + this.vm.changeFontSize}`)
                .borderRadius(12)
                .fontFamily('鸿蒙黑体')
          }
          .margin({top: 10, left:56})
          .width('100%')
          Row() {
              Flex({justifyContent:FlexAlign.SpaceBetween}) {
                Row(){
                  Text('5分钟前')
                    .margin({right:16})
                    .fontColor(Color.Gray)
                    .fontSize(`${10 + this.vm.changeFontSize}`)
                  Text('南京')
                    .fontColor(Color.Gray)
                    .fontSize(`${10 + this.vm.changeFontSize}`)
                }
                .width('50%')

                Row(){
                  Image(this.likeFlag ? $r('app.media.hand_thumbsup_fill') : $r('app.media.hand_thumbsup'))
                    .width(16)
                    .height(16)
                    .margin({right:6})
                  Text(JSON.stringify(this.counts))
                    .onClick(() => {
                      this.likeFlag = !this.likeFlag;
                      if(this.likeFlag) {
                        this.counts ++;
                      } else {
                        this.counts --;
                      }

                    })
                }
                .width('15%')
              }
          }
          .margin({top: 10,left:30})
        }
        .margin({ left:16,top:16,bottom:40,right:10 })
      }
    }
    .margin({ top: 8,bottom:16 })
  }

  build() {
    NavDestination(){
      Column() {
        Row() {
          Text('住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？')
            .fontSize(`${16 + this.vm.changeFontSize}`)
            .fontFamily('鸿蒙黑体')
            .fontWeight('bold')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({top: 20, left:14, right:14})
        }
        .width('100%')
        Divider()
          .margin({ top: 12 })
          .strokeWidth(8)
          .color('#F1F3F5')
        Row() {
          Text('评论·99')
            .fontSize(`${18 + this.vm.changeFontSize}`)
            .fontFamily('鸿蒙黑体')
            .fontWeight('bold')
        }
        .margin({top: 20, left:30})
        .width('100%')
        Scroll() {
          this.AllComment()
        }
      }
      .width('100%')
    }
    .title('评论详情')}
}
