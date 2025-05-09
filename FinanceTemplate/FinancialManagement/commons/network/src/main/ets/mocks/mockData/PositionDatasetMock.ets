import { FormatUtil } from 'commonlib'
import { ICodeRequest, IQueryData, SubmitPositionRedemptionRequest } from '../../types/AxiosRequestParam'
import { IPositionRecord } from '../../types/responseTypes/GetPositionInfoResp'
import { IPositionItem } from '../../types/responseTypes/GetPositionListResp'
import { ITransactionInfo } from '../../types/responseTypes/GetTransactionRecordInfoResp'
import { ITransactionItem } from '../../types/responseTypes/GetTransactionRecordListResp'
import {
  MockStorageMap,
  positionInfo,
  positionItem1,
  positionItem2,
  positionItem3,
  positionItem4,
  positionItem5,
  redemption
} from '../Constants'
import { getFormattedResp } from '../Utils'
import { TransactionDatasetMock } from './TransactionDatasetMock'

export class PositionDatasetMock {
  static positionList: IPositionItem[] = [positionItem1, positionItem2, positionItem3, positionItem4, positionItem5]

  public static getPositionList() {
    return getFormattedResp(PositionDatasetMock.positionList)
  }

  public static getPositionInfo(data: IQueryData) {
    const position = PositionDatasetMock.positionList.find((item) => {
      return item.id === data.id
    })
    if (position) {
      const arr = Object.keys(position)
      for (let item of arr) {
        Reflect.set(positionInfo, item, Reflect.get(position, item))
      }
    }
    return getFormattedResp(positionInfo)
  }

  public static getPositionRedemption(data: IQueryData) {
    const position = PositionDatasetMock.positionList.find((item) => {
      return item.id === data.id
    })
    if (position) {
      const arr = Object.keys(position)
      for (let item of arr) {
        Reflect.set(redemption, item, Reflect.get(position, item))
      }
    }
    return getFormattedResp(redemption)
  }

  public static sendVerificationCode(userId: number) {
    const verificationCode = '123456'
    AppStorage.setOrCreate(MockStorageMap.VERIFICATION_CODE, verificationCode);
    return getFormattedResp(undefined);
  }

  public static submitVerificationCode(data: ICodeRequest) {
    let verificationCode = AppStorage.get<string>(MockStorageMap.VERIFICATION_CODE);
    if (verificationCode && verificationCode === data.code) {
      return getFormattedResp(1);
    }
    return getFormattedResp(0);
  }

  public static submitPositionRedemption(data: SubmitPositionRedemptionRequest) {
    const transactionItem: ITransactionItem = {
      id: TransactionDatasetMock.transactionList.length + 1,
      type: 3,
      amount: 1020,
      share: 23,
      date: FormatUtil.formatDate(new Date()),
      productName: '',
      bankCardNo: '',
    }
    const transactionInfo: ITransactionInfo = {
      id: 1,
      type: 3,
      state: 1,
      date: '',
      productName: '',
      productNumber: 'WE12312',
      bankCardNumber: '',
      amount: 1000,
      status: [
        {
          date: '2023/02/27',
          status: 1,
        },
        {
          date: '2023/02/27',
          status: 0,
        }
      ]
    }
    const position = PositionDatasetMock.positionList.find((item) => {
      return item.id === data.id
    })
    if (position) {
      transactionItem.share = data.share
      transactionItem.productName = position.productName
      transactionItem.bankCardNo = data.bankCardNo
      TransactionDatasetMock.transactionList.push(transactionItem)
      transactionInfo.id = transactionItem.id
      transactionInfo.date = transactionItem.date
      transactionInfo.productName = position.productName
      transactionInfo.bankCardNumber = data.bankCardNo
      TransactionDatasetMock.transactionInfoList.push(transactionInfo)
    }
    return getFormattedResp(1)
  }

  public static getPositionRecord(data: IQueryData) {
    const positionRecord: IPositionRecord[] = [
      {
        id: 1,
        type: 2,
        date: '2019-04-06',
        time: '10:34:21',
        amount: 200,
        state: 1
      },
      {
        id: 2,
        type: 2,
        date: '2019-04-06',
        time: '10:34:21',
        amount: 200,
        state: 1
      },
      {
        id: 3,
        type: 2,
        date: '2019-04-06',
        time: '10:34:21',
        amount: 200,
        state: 1
      }
    ]
    return getFormattedResp(positionRecord)
  }
}