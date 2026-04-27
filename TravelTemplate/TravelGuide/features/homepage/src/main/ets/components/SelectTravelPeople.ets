import { RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { TravelPeopleListModel, TravelPeopleModel } from 'common_travel_guide';
import { TravelPeopleAddPageBuilder } from '../view/TravelPeopleAddPage'
import { TravelPeopleListPageBuilder } from '../view/TravelPeopleListPage'
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct SelectTravelPeople {
  private controller: TextInputController = new TextInputController();
  @Param title: string = '出行人'
  @Param routerPhone: string | number = ''
  @Param routerPeopleList: TravelPeopleModel[] = [];
  @Local phoneText: string | number = ''
  @Local selectPeopleList: TravelPeopleModel[] = [];
  @Event onConfirm: (list: TravelPeopleModel[], phone: string | number) => void = () => {
  }
  @Local peopleList: TravelPeopleListModel =
    PersistenceV2.connect(TravelPeopleListModel, 'TravelPeopleList', () => new TravelPeopleListModel())!;

  //跳转到新增、编辑出行人页面
  jumpTravelPeopleAddPage(item: TravelPeopleModel | null) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TRAVEL_PEOPLE_ADD_PAGE,
      builder: wrapBuilder(TravelPeopleAddPageBuilder),
      param: item,
      onPop: () => {
        this.updateSelectPeopleList()
      }
    })
  }

  // 跳转到出行人列表
  jumpTravelPeopleListPage() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.TRAVEL_PEOPLE_LIST_PAGE,
      builder: wrapBuilder(TravelPeopleListPageBuilder),
      param: this.routerPeopleList,
      onPop: () => {
        this.updateSelectPeopleList()
      }
    })
  }

  updateSelectPeopleList() {
    let result = this.peopleList.list.filter((item: TravelPeopleModel) => item.isCheck)
    this.selectPeopleList = result;
    this.onConfirm(this.selectPeopleList, this.phoneText)
  }

  // 填写手机号
  getPhoneNumber(phone: string) {
    this.phoneText = phone;
    this.onConfirm(this.selectPeopleList, this.phoneText)
  }

  aboutToAppear(): void {
    this.phoneText = this.routerPhone
    this.selectPeopleList = this.routerPeopleList;
  }

  build() {
    Column() {
      Column() {
        this.titleHeader()
        this.selectTravelListBuilder()
      }
      .padding({
        right: 12,
        left: 12,
      })

      if (this.selectPeopleList.length) {
        Column() {
          this.contactPhoneBuilder()
        }
        .padding({
          left: 12,
          right: 12,
        })
        .backgroundColor('#FAFBFC')
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ top: 16 })
    .borderRadius(16)
    .clip(true)
    .margin({ bottom: 10 })
  }

  @Builder
  titleHeader() {
    Row() {
      Text(`选择${this.title}`)
      Row() {
        Image($r('app.media.add_people'))
          .width(14)
          .height(14)
          .margin({ right: 4 })
        Text(`更多${this.title}`)
      }
      .backgroundColor('#FFF9D6')
      .borderRadius(14)
      .padding({
        left: 8,
        right: 8,
        top: 6,
        bottom: 6
      })
      .onClick(() => {
        this.jumpTravelPeopleListPage();
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 13 })
  }

  @Builder
  selectTravelListBuilder() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.selectPeopleList, (item: TravelPeopleModel, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.name)
                  .fontSize(14)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                Row() {
                  Text('身份证 ')
                    .fontSize(14)
                    .fontColor('#333')
                    .opacity(0.5)
                  Text(item.maskedIdNumber)
                    .fontColor('#333')
                    .fontSize(14)
                    .opacity(0.5)
                }
                .margin({ top: 4 })
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .layoutWeight(1)
              .margin({ right: 14 })

              Image($r('app.media.ic_edit'))
                .width(18)
                .height(18)
                .onClick(() => {
                  this.jumpTravelPeopleAddPage(item)
                })
            }
            .alignItems(VerticalAlign.Center)
            .height(60)
          }
        },(item: TravelPeopleModel) => JSON.stringify(item))
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
      .borderRadius(16)
    }
  }

  @Builder
  contactPhoneBuilder() {
    Row() {
      Text('联系电话')
        .fontSize(14)
        .margin({ right: 24 })
        .fontColor('#333')
      TextInput({ placeholder: '请输入手机号', text: `${this.phoneText}`, controller: this.controller })
        .type(InputType.PhoneNumber)
        .height(36)
        .layoutWeight(1)
        .fontSize(14)
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .fontColor('#333')
        .backgroundColor(Color.Transparent)
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: {
            size: 16,
            src: $r('app.media.icon_delete'),
          }
        })
        .onChange((event) => {
          this.getPhoneNumber(event)
        })
    }
    .width('100%')
    .height(52)
  }
}
