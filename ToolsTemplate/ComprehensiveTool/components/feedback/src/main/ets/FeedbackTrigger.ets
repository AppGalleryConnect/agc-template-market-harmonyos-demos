import { uiObserver } from '@kit.ArkUI';
import { PageName } from './common/CustomTypes';
import { FileUtils } from './utils/FileUtils';

@ComponentV2
export struct FeedbackTrigger {

  private navPathStack: NavPathStack | null = null;

  @BuilderParam
  public contentBuilder: () => void = buildEmptyContent;

  @Event
  public onBeforeNavigate: () => boolean = () => true;

  public aboutToAppear(): void {
    FileUtils.initUIContext(this.getUIContext());
    const navigationInfo: uiObserver.NavigationInfo | undefined = this.queryNavigationInfo();
    if (navigationInfo) {
      this.navPathStack = navigationInfo.pathStack;
    }
  }

  public build(): void {
    Column() {
      this.contentBuilder()
    }
    .width('auto')
    .height('auto')
    .onClick(() => {
      if (this.navPathStack && this.onBeforeNavigate()) {
        this.navPathStack.pushPathByName(PageName.FeedbackSubmit, null);
      }
    })
  }
}

@Builder
function buildEmptyContent() {
  // No need to do anything
}
