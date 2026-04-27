import { CustomTitle } from '../components/CustomTitle';
import { VideoList } from '../components/VideoList';
import { RouterMap, getInstance } from '../util/Route';
import { CastService } from '../service/CastService';
import { toastUtil } from '../util/ToastUtil';


@Builder
export function FileListPageBuilder() {
  FileListPage();
}

@ComponentV2
export struct FileListPage {
  build() {
    NavDestination() {
      CustomTitle({
        title: '视频',
      });
      Column() {
        VideoList({
          onSelect: (param) => {
            if (CastService.getInstance().castStatusModel.isCasting) {
              getInstance().pushPathByName(RouterMap.CONTROLLER, param);
            } else {
              toastUtil.showToast('设备连接已断开！');
            }
          },
        });
      }.layoutWeight(1)
      .padding({
        top: 12,
        bottom: 12,
        left: 16,
        right: 16,
      });

    }.hideTitleBar(true);
  }
}



