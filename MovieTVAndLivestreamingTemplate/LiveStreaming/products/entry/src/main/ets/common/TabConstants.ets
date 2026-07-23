/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { RouterMap } from '@agctemplate/router_module';
import {
  PrivacyAgreementBuilder,
  PrivacyStatementPageBuilder,
  PrivacyUseAlertBuilder,
  PrivacyPageBuilder,
  SetUpPageBuilder,
  FeedbackPageBuilder,
  FeedbackRecordPageBuilder,
  AboutPageBuilder,
  EditPersonalCenterBuilder,
  AuthenticationPageBuilder,
  TermsOfServicePageBuilder,
  MessageCenterBuilder,
  NewFansMessagePageBuilder,
  SystemMessagePageBuilder,
  WatchRecordPageBuilder,
  PrivacySettingsPageBuilder,
  Privacy3rdPartySharePageBuilder,
  PrivacyInfoCollectPageBuilder,
  AnchorCenterBuilder,
  VideoRecordPlayPageBuilder
} from '@agctemplate/mine';

import { LoginPageBuilder } from '../pages/LoginPage';
import { MainPageBuilder } from '../pages/MainPage';
import {
  CommentKeyboardBuild,
  DetailPageBuilder, FollowersPageBuilder, FollowingPageBuilder, ProfilePageBuilder } from '@agctemplate/detail';
import { SearchPageBuilder } from '@agctemplate/home'
import { CameraPageBuilder,EndLivePageBuilder } from '@agctemplate/live'
import { RealNameAuthPageBuilder } from 'module_auth'

export class TabStyle {
  static readonly BAR_HEIGHT = 48;
  static readonly ANIMATION_DURATION = 0;
  static readonly ICON_SIZE = 24;
}

export class RouterTable {
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();

  // 初始化路由表
  public static routerInit() {
    RouterTable.builderMap.set(RouterMap.MAIN_PAGE, wrapBuilder(MainPageBuilder));
    RouterTable.builderMap.set(RouterMap.LOGIN_PAGE, wrapBuilder(LoginPageBuilder));
    RouterTable.builderMap.set(RouterMap.SEARCH_PAGE, wrapBuilder(SearchPageBuilder))

    // --------------------------------------------------我的
    RouterTable.builderMap.set(RouterMap.PRIVACY_PAGE, wrapBuilder(PrivacyPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_STATEMENT_PAGE, wrapBuilder(PrivacyStatementPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_AGREEMENT_PAGE, wrapBuilder(PrivacyAgreementBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_USE_PAGE, wrapBuilder(PrivacyUseAlertBuilder));
    RouterTable.builderMap.set(RouterMap.SET_UP_PAGE, wrapBuilder(SetUpPageBuilder));
    RouterTable.builderMap.set(RouterMap.FEEDBACK_PAGE, wrapBuilder(FeedbackPageBuilder));
    RouterTable.builderMap.set(RouterMap.FEEDBACK_RECORD_PAGE, wrapBuilder(FeedbackRecordPageBuilder));
    RouterTable.builderMap.set(RouterMap.ABOUT_PAGE, wrapBuilder(AboutPageBuilder));
    RouterTable.builderMap.set(RouterMap.PERSONAL_CENTER_PAGE, wrapBuilder(EditPersonalCenterBuilder));
    RouterTable.builderMap.set(RouterMap.AUTHENTICATION_PAGE, wrapBuilder(AuthenticationPageBuilder));
    RouterTable.builderMap.set(RouterMap.TERMS_SERVICE_PAGE, wrapBuilder(TermsOfServicePageBuilder));
    RouterTable.builderMap.set(RouterMap.MESSAGE_CENTER_PAGE, wrapBuilder(MessageCenterBuilder));
    RouterTable.builderMap.set(RouterMap.SYS_MESSAGE_PAGE, wrapBuilder(SystemMessagePageBuilder));
    RouterTable.builderMap.set(RouterMap.NEW_FANS_MESSAGE_PAGE, wrapBuilder(NewFansMessagePageBuilder));
    RouterTable.builderMap.set(RouterMap.WATCH_RECORD, wrapBuilder(WatchRecordPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_SETTINGS_PAGE, wrapBuilder(PrivacySettingsPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_3RD_PARTY_SHARE_PAGE, wrapBuilder(Privacy3rdPartySharePageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_INFO_COLLECT_PAGE, wrapBuilder(PrivacyInfoCollectPageBuilder));
    RouterTable.builderMap.set(RouterMap.ANCHOR_CENTER_PAGE, wrapBuilder(AnchorCenterBuilder));
    RouterTable.builderMap.set(RouterMap.VIDEO_RECORD_PLAY_PAGE, wrapBuilder(VideoRecordPlayPageBuilder));


    // --------------------------------------------------详情播放
    RouterTable.builderMap.set(RouterMap.DETAIL_PAGE, wrapBuilder(DetailPageBuilder));
    // 个人页面
    RouterTable.builderMap.set(RouterMap.PROFILE_PAGE, wrapBuilder(ProfilePageBuilder));
    RouterTable.builderMap.set(RouterMap.FOLLOWING_PAGE, wrapBuilder(FollowingPageBuilder));
    RouterTable.builderMap.set(RouterMap.FOLLOWERS_PAGE, wrapBuilder(FollowersPageBuilder));
    // 输入框
    RouterTable.builderMap.set(RouterMap.COMMENT_KEY_BOARD_PAGE, wrapBuilder(CommentKeyboardBuild));

    // --------------------------------------------------直播
    RouterTable.builderMap.set(RouterMap.Camera_Page, wrapBuilder(CameraPageBuilder));
    //直播界面
    RouterTable.builderMap.set(RouterMap.End_Live_Page, wrapBuilder(EndLivePageBuilder));
    //直播结算界面
    RouterTable.builderMap.set(RouterMap.Real_Name_Auth_Page, wrapBuilder(RealNameAuthPageBuilder));
    //实名认证页面
  }

  // 通过名称获取builder
  public static getBuilder(builderName: string): WrappedBuilder<[]> {
    let builder = RouterTable.builderMap.get(builderName);
    return builder as WrappedBuilder<[]>;
  }
}


