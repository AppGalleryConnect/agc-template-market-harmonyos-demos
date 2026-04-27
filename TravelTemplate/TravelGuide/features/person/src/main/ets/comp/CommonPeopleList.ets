import { PersistenceV2 } from '@kit.ArkUI';
import { RouterMap } from 'common';
import { TravelPeopleListModel, TravelPeopleModel, baseToast } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { CommonPeopleAddPageBuilder } from '../views/CommonPeopleAddPage'

@ComponentV2
export struct CommonPeopleList {
  @Local peopleList: TravelPeopleListModel =
    PersistenceV2.connect(TravelPeopleListModel, 'TravelPeopleList', () => new TravelPeopleListModel())!;

  //跳转到新增、编辑出行人页面
  jumpCommonPeopleAddPage(item: TravelPeopleModel | null) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.COMMON_PEOPLE_ADD_PAGE,
      builder: wrapBuilder(CommonPeopleAddPageBuilder),
      param: item
    })
  }

  build() {
    Column({ space: 10 }) {
      // 旅客列表
      ForEach(this.peopleList.list, (item: TravelPeopleModel) => {
        this.infoCardBuilder(item)
      }, (item: TravelPeopleModel) => JSON.stringify(item))
      this.listAddButton()
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  infoCardBuilder(item: TravelPeopleModel) {
    Column({ space: 8 }) {
      this.cardTitleBuilder(item)
      this.cardContentRow('身份证号', item.maskedIdNumber ?? '')
      this.cardContentRow('手机号码', item.maskedPhone ?? '')
      Row() {
        Text('删除')
          .textBtnStyle()
          .onClick(() => {
            baseToast.show({
              type: 'dialog',
              message: '确认删除旅客吗？',
              cancelColor: 'rgba(0,0,0,0.5)',
              confirmAction: () => {
                this.peopleList.removeList(item)
                baseToast.hide();
              },
              cancelAction: () => {
              },
            });
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .backgroundColor('#fff')
    .borderRadius(16)
    .padding(12)
  }

  @Builder
  cardTitleBuilder(item: TravelPeopleModel) {
    Row() {
      Row({ space: 4 }) {
        Text(item.name)
          .fontSize(16)
          .fontWeight(500)
          .fontColor('#000')
        if (this.peopleList.myselfId === item.id) {
          Text('本人')
            .fontSize(10)
            .fontColor('#2F7CFF')
            .padding({
              left: 4,
              right: 4,
              top: 2,
              bottom: 2
            })
            .borderRadius(4)
            .border({ width: 1, color: '#99BFFF' })
        }
      }

      Image($r('app.media.ic_edit_card'))
        .width(20)
        .height(20)
        .onClick(() => {
          this.jumpCommonPeopleAddPage(item);
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  cardContentRow(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .width(52)
        .fontSize(13)
        .fontColor('rgba(0, 0, 0, 0.50)')
      Text(value)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor('rgba(0, 0, 0, 0.50)')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  listAddButton() {
    Row() {
      Row({ space: 5 }) {
        Image($r('app.media.ic_plus_circle'))
          .width(14)
          .height(14)
        Text('新增常用人')
          .fontSize(14)
          .fontColor('#333333')
      }
    }
    .width('100%')
    .borderRadius(24)
    .padding({ top: 13, bottom: 13 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff')
    .onClick(() => {
      this.jumpCommonPeopleAddPage(null)
    })
  }
}

@Extend(Text)
function textBtnStyle() {
  .fontSize(12)
  .fontColor('rgba(0, 0, 0, 0.70)')
  .padding({
    top: 8,
    bottom: 8,
    left: 26,
    right: 26
  })
  .backgroundColor('#fff')
  .borderRadius(10)
  .border({ width: 1, color: 'rgba(0, 0, 0, 0.10)' })
}