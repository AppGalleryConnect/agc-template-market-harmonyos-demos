import { EnglishZonePage } from '@ohos_agcit/children_education_englishzone';
import { CartoonPage } from '@ohos_agcit/children_education_cartoon';
import { SelectedPage } from '@ohos_agcit/children_education_selected';
import { SingPage } from '@ohos_agcit/children_education_sing';
import { ChinesePage } from '@ohos_agcit/children_education_chinese';
import { CommonConstants, DialogUtils } from '@ohos_agcit/children_education_utils';

@ComponentV2
export struct HomePage {
  @Local currentIndex: number = 0;
  private ageArray: Resource = $r('app.strarray.age_array');
  @Provider('age') age: string = '0-3岁';

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column(){
      Text(name)
        .fontColor(Color.Black)
        .fontSize(14)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? $r('sys.color.black') : Color.Gray)
        .lineHeight(22)
        .margin({ top: 17, bottom: 10 })

      // Divider()
      //   .width(36)
      //   .strokeWidth(2)
      //   .color(Color.Black)
      //   .opacity(this.currentIndex === index ? 1 : 0)
    }
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Row() {
          }
          .borderRadius(20)
          .backgroundColor('#F1F3F5')
          .width('30%')
          .height('100%');

          Row() {
            Text(this.age)
              .fontSize(16);
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .padding({
                left: '2%',
              });
          };
        };
      }
      .margin({
        top: 10
      })
      .height(36)
      .alignSelf(ItemAlign.Start)
      .padding({
        left: '4%',
      })
      .onClick(() => {
        DialogUtils.textPickerDialog(this.ageArray, (sexValue: string) => {
          this.age = sexValue;
        });
      });

      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          SelectedPage();
        }
        .tabBar(this.tabBuilder(0, $r('app.string.selected')));

        TabContent() {
          CartoonPage();
        }
        .tabBar(this.tabBuilder(1, $r('app.string.cartoon')));

        TabContent() {
          EnglishZonePage();
        }
        .tabBar(this.tabBuilder(2, $r('app.string.english_zone')));

        TabContent() {
          SingPage();
        }
        .tabBar(this.tabBuilder(3, $r('app.string.sing')));

        TabContent() {
          ChinesePage();
        }
        .tabBar(this.tabBuilder(4, $r('app.string.chinese')));
      }
      .barWidth(CommonConstants.FULL_PERCENT)
      .barHeight(52)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .align(Alignment.Center)
      .animationDuration(300)
      .onAnimationStart((index: number, targetIndex: number) => {
        this.currentIndex = targetIndex;
      });
    };
  };
}