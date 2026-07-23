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

import { RouterMap } from 'commonlib';

import {
  ChapterPracticeBuilder,
  FeaturedCoursesBuilder,
  MaterialDownloadBuilder,
  SearchInputBuilder,
  SearchPageBuilder,
  SecondListBuilder,
  ThirdListBuilder,
  TopicHomePageBuilder,
} from 'homepage';

import {
  AnswerQuestionsBuilder,
  AnswerQuestionsTwoBuilder,
  CourseIntroductionBuilder,
  ExamResultBuilder,
  GoodCourseDetailBuilder,
  MockTestPageBuilder,
  MyCollectionPageBuilder,
  MyNotesPageBuilder,
  MyWrongPageBuilder,
  TestReportBuilder,
  ViewNotePageBuilder
} from 'topicpage';

import {
  AboutPageBuilder,
  BrowsingHistoryBuilder,
  CollectionBuilder,
  CoursePageBuilder,
  EditPersonalCenterBuilder,
  MessageCenterBuilder,
  MyOrderBuilder,
  OneDayPracticeRecordsBuilder,
  OrderDetailBuilder,
  PracticeDetailsBuilder,
  PracticeRecordsBuilder,
  PrivacyAgreementBuilder,
  PrivacyStatementPageBuilder,
  PrivacyUseAlertBuilder,
  SetUpPageBuilder,
  TermsOfServicePageBuilder,
  AuthenticationPageBuilder,
  PrivacyPageBuilder,
  CustomServicePageBuilder,
  MyDownloadPageBuilder,
  MemberCenterPageBuilder
} from 'minepage';

import { LoginPageBuilder } from '../pages/LoginPage';
import { MainEntryBuilder } from '../pages/MainEntry';
import { LaunchAdPageBuilder } from '../pages/LaunchAdPage';
import { buildFeedbackSubmitPage } from 'feedback/src/main/ets/pages/FeedbackSubmitPage';
import { buildFeedbackHistoryPage } from 'feedback/src/main/ets/pages/FeedbackHistoryPage';
import { SettingAbout, SettingAboutBuilder } from 'app_setting/src/main/ets/pages/SettingAbout';
import { ResultPage, ResultPageBuilder } from 'search/src/main/ets/views/ResultPage';

export class RouterTable {
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();

  // 初始化路由表
  public static routerInit() {
    RouterTable.builderMap.set(RouterMap.MAIN_PAGE, wrapBuilder(MainEntryBuilder));
    RouterTable.builderMap.set(RouterMap.LOGIN_PAGE, wrapBuilder(LoginPageBuilder));
    RouterTable.builderMap.set(RouterMap.LAUNCH_AD_PAGE, wrapBuilder(LaunchAdPageBuilder));
    // --------------------------------------------------练习
    RouterTable.builderMap.set(RouterMap.CHAPTER_PRACTICE_PAGE, wrapBuilder(ChapterPracticeBuilder));
    RouterTable.builderMap.set(RouterMap.FEATURE_COURSE_PAGE, wrapBuilder(FeaturedCoursesBuilder));
    RouterTable.builderMap.set(RouterMap.MATERIAL_DOWNLOAD_PAGE, wrapBuilder(MaterialDownloadBuilder));
    RouterTable.builderMap.set(RouterMap.SEARCH_PAGE, wrapBuilder(SearchPageBuilder));
    RouterTable.builderMap.set(RouterMap.SEARCH_INPUT_PAGE, wrapBuilder(SearchInputBuilder));
    // --------------------------------------------------课程
    RouterTable.builderMap.set(RouterMap.ANSWER_QUESTIONS_PAGE, wrapBuilder(AnswerQuestionsBuilder));
    RouterTable.builderMap.set(RouterMap.ANSWER_QUESTIONS_TWO_PAGE, wrapBuilder(AnswerQuestionsTwoBuilder));
    RouterTable.builderMap.set(RouterMap.ANSWER_REPORT_PAGE, wrapBuilder(TestReportBuilder));
    RouterTable.builderMap.set(RouterMap.EXAM_RESULT_PAGE, wrapBuilder(ExamResultBuilder));
    RouterTable.builderMap.set(RouterMap.GOOD_COURSE_DETAIL_PAGE, wrapBuilder(GoodCourseDetailBuilder));
    RouterTable.builderMap.set(RouterMap.MY_WRONG_PAGE, wrapBuilder(MyWrongPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_COLLECTION_PAGE, wrapBuilder(MyCollectionPageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_NOTE_PAGE, wrapBuilder(MyNotesPageBuilder));
    RouterTable.builderMap.set(RouterMap.View_NOTE_PAGE, wrapBuilder(ViewNotePageBuilder));
    RouterTable.builderMap.set(RouterMap.Mock_PAGE, wrapBuilder(MockTestPageBuilder));
    RouterTable.builderMap.set(RouterMap.COURSE_INTRODUCTION_PAGE, wrapBuilder(CourseIntroductionBuilder));
    RouterTable.builderMap.set(RouterMap.Level_TWO_PAGE, wrapBuilder(SecondListBuilder));
    RouterTable.builderMap.set(RouterMap.Level_THREE_PAGE, wrapBuilder(ThirdListBuilder));
    RouterTable.builderMap.set(RouterMap.Level_ONE_PAGE, wrapBuilder(TopicHomePageBuilder));
    // --------------------------------------------------我的
    RouterTable.builderMap.set(RouterMap.SET_UP_PAGE, wrapBuilder(SetUpPageBuilder));
    RouterTable.builderMap.set(RouterMap.FEEDBACK_PAGE, wrapBuilder(buildFeedbackSubmitPage));
    RouterTable.builderMap.set(RouterMap.FEEDBACK_RECORD_PAGE, wrapBuilder(buildFeedbackHistoryPage));
    RouterTable.builderMap.set(RouterMap.ABOUT_PAGE, wrapBuilder(AboutPageBuilder));
    RouterTable.builderMap.set(RouterMap.PERSONAL_CENTER_PAGE, wrapBuilder(EditPersonalCenterBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_STATEMENT_PAGE, wrapBuilder(PrivacyStatementPageBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_AGREEMENT_PAGE, wrapBuilder(PrivacyAgreementBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_USE_PAGE, wrapBuilder(PrivacyUseAlertBuilder));
    RouterTable.builderMap.set(RouterMap.COURSE_PAGE, wrapBuilder(CoursePageBuilder));
    RouterTable.builderMap.set(RouterMap.PRACTICE_RECORDS_PAGE, wrapBuilder(PracticeRecordsBuilder));
    RouterTable.builderMap.set(RouterMap.PRACTICE_DETAILS_PAGE, wrapBuilder(PracticeDetailsBuilder));
    RouterTable.builderMap.set(RouterMap.DAY_PRACTICE_DETAILS_PAGE, wrapBuilder(OneDayPracticeRecordsBuilder));
    RouterTable.builderMap.set(RouterMap.MESSAGE_CENTER_PAGE, wrapBuilder(MessageCenterBuilder));
    RouterTable.builderMap.set(RouterMap.COLLECTION_PAGE, wrapBuilder(CollectionBuilder));
    RouterTable.builderMap.set(RouterMap.MY_ORDER_PAGE, wrapBuilder(MyOrderBuilder));
    RouterTable.builderMap.set(RouterMap.Order_Detail_PAGE, wrapBuilder(OrderDetailBuilder));
    RouterTable.builderMap.set(RouterMap.BROWSING_HISTORY_PAGE, wrapBuilder(BrowsingHistoryBuilder));
    RouterTable.builderMap.set(RouterMap.PRIVACY_PAGE, wrapBuilder(PrivacyPageBuilder));
    RouterTable.builderMap.set(RouterMap.AUTHENTICATION_PAGE, wrapBuilder(AuthenticationPageBuilder));
    RouterTable.builderMap.set(RouterMap.TERMS_SERVICE_PAGE, wrapBuilder(TermsOfServicePageBuilder));
    RouterTable.builderMap.set(RouterMap.CUSTOM_SERVICE_PAGE, wrapBuilder(CustomServicePageBuilder));
    RouterTable.builderMap.set(RouterMap.MY_DOWNLOAD_PAGE, wrapBuilder(MyDownloadPageBuilder));
    RouterTable.builderMap.set(RouterMap.SETTING_ABOUT, wrapBuilder(SettingAboutBuilder));
    RouterTable.builderMap.set(RouterMap.MEMBER_CENTER_PAGE, wrapBuilder(MemberCenterPageBuilder));
    RouterTable.builderMap.set(RouterMap.RESULT_PAGE, wrapBuilder(ResultPageBuilder));
  }

  // 通过名称获取builder
  public static getBuilder(builderName: string): WrappedBuilder<[]> {
    let builder = RouterTable.builderMap.get(builderName);
    return builder as WrappedBuilder<[]>;
  }
}
