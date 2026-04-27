import { CardRecognition, CardRecognitionResult, CardSide, CardType, ShootingMode } from '@kit.VisionKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[CardRecognitionPage]';

@Builder
export function cardRecognitionPageBuilder() {
  CardRecognitionPage();
}

@ComponentV2
export struct CardRecognitionPage {
  @Local pageStack: NavPathStack = new NavPathStack();
  @Local cardDataSource: Record<string, string>[] = [];
  @Local idCardSide: CardSide = CardSide.DEFAULT;

  build() {
    NavDestination() {
      Column() {
        if (canIUse('SystemCapability.AI.Component.CardRecognition')) {
          CardRecognition({
            supportType: CardType.CARD_ID,
            cardSide: this.idCardSide,
            cardRecognitionConfig: {
              defaultShootingMode: ShootingMode.MANUAL,
              isPhotoSelectionSupported: true,
            },
            onResult: ((params: CardRecognitionResult) => {
              UtilLog.info(TAG, `params code: ${params.code}, cardType: ${params.cardType}`);
              if (params.code !== 200) {
                this.pageStack.pop();
              }
              if (params.cardInfo?.front !== undefined) {
                const data = params.cardInfo.front;
                UtilLog.info(TAG, `cardInfo front: ${JSON.stringify(data)}`);
                this.pageStack.pop(data.cardImageUri);
              }
              if (params.cardInfo?.back !== undefined) {
                const data = params.cardInfo.back;
                UtilLog.info(TAG, `cardInfo back: ${JSON.stringify(data)}`);
                this.pageStack.pop(data.cardImageUri);
              }
            })
          });
        }
      }
      .width('100%')
      .height('100%');
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
      this.idCardSide = context.pathInfo.param as CardSide;
    })
    .width('100%')
    .height('100%')
    .hideTitleBar(true);
  }
}