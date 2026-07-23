import { HomeMainPageBuilder } from '@agctemplate/home';
import { MineMainPageBuilder } from '@agctemplate/mine';
import { TheaterMainPageBuilder } from '@agctemplate/theater'
import { AwardMainPageBuilder } from '@agctemplate/award';
import { FavorMainPageBuilder } from '@agctemplate/favor';
import { MinorsProtectionUtils } from '@agctemplate/widgets';
import { getMedia, getString } from '@agctemplate/resources';
import { TabHeaderInfo, TabInfoRegister } from '../../../../../Index';

export function initMainPageContent() {
  TabInfoRegister.tabInfos = MinorsProtectionUtils.getMinorsMode() ? [{
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.theater'), false, $r('sys.symbol.play_video_fill')),
    tabContentBuilder: wrapBuilder(TheaterMainPageBuilder)
  }, {
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.mine'), false, $r('sys.symbol.person_fill')),
    tabContentBuilder: wrapBuilder(MineMainPageBuilder)
  }] : [{
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.home'), false, $r('sys.symbol.house_fill')),
    tabContentBuilder: wrapBuilder(HomeMainPageBuilder)
  }, {
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.theater'), false, $r('sys.symbol.play_video_fill')),
    tabContentBuilder: wrapBuilder(TheaterMainPageBuilder)
  }, {
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.award'), false, $r('sys.symbol.moneybag')),
    tabContentBuilder: wrapBuilder(AwardMainPageBuilder)
  }, {
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.favor'), false, $r('sys.symbol.star_circle_fill')),
    tabContentBuilder: wrapBuilder(FavorMainPageBuilder)
  }, {
    tabHeaderInfo: new TabHeaderInfo(getString('app.string.mine'), false, $r('sys.symbol.person_fill')),
    tabContentBuilder: wrapBuilder(MineMainPageBuilder)
  }];
}