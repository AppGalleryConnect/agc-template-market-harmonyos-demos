import { CommonDataSource } from 'lib_common';
import { RequestListData, AuthorModel, AvModel } from 'lib_news_api';

export class LayoutNewsDataSource extends CommonDataSource<RequestListData> {
}

export class AuthorDataSource extends CommonDataSource<AuthorModel> {
}

export class SubscribeDataSource extends CommonDataSource<AvModel> {
}

