import { IQueryById, IQueryTransaction } from '../../types/AxiosRequestParam';
import { IProductItem } from '../../types/responseTypes/GetProductResp'
import { ITransactionInfo } from '../../types/responseTypes/GetTransactionRecordInfoResp';
import { IMonthTransactionItem, ITransactionItem } from '../../types/responseTypes/GetTransactionRecordListResp';
import {
  product1,
  product2,
  product3,
  product4,
  product5,
  product6,
  product7,
  product8,
  product9,
  product10,
  product11,
  product12,
  transactionItem1,
  transactionItem2,
  transactionItem3,
  transactionItem4,
  transactionItem5,
  transactionItem6,
  transactionInfo1,
  transactionInfo2,
  transactionInfo3,
  transactionInfo4,
  transactionInfo5,
  transactionInfo6,
} from '../Constants';
import { getFormattedResp } from '../Utils';

export class TransactionDatasetMock {
  static productList: IProductItem[] =
    [product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11,
      product12]
  static transactionList: ITransactionItem[] =
    [transactionItem1, transactionItem2, transactionItem3, transactionItem4, transactionItem5, transactionItem6]
  static transactionInfoList: ITransactionInfo[] =
    [transactionInfo1, transactionInfo2, transactionInfo3, transactionInfo4, transactionInfo5, transactionInfo6,]

  public static getMonthTransactionList(data: IQueryTransaction) {
    let monthTransactionList: IMonthTransactionItem[] = []

    if (data.searchText) {
      const arr = TransactionDatasetMock.transactionList.filter((item) => {
        return item.productName.includes(data.searchText as string)
      })
      arr.forEach((item) => {
        const date = item.date.slice(0, 7)
        if (monthTransactionList.length === 0) {
          const monthTransactionItem: IMonthTransactionItem = {
            month: date,
            transactionList: [item]
          }
          monthTransactionList.push(monthTransactionItem)
        } else {
          for (let index = 0; index < monthTransactionList.length; index++) {
            const element = monthTransactionList[index];
            if (date === element.month) {
              const res = element.transactionList.find((child) => {
                return child.id === item.id
              })
              if (!res) {
                element.transactionList.push(item)
              }
              break
            }
            if (date !== element.month && index === monthTransactionList.length - 1) {
              const monthTransactionItem: IMonthTransactionItem = {
                month: date,
                transactionList: [item]
              }
              monthTransactionList.push(monthTransactionItem)
            }
          }
        }
      })
      return getFormattedResp(monthTransactionList);
    }

    TransactionDatasetMock.transactionList.forEach((item) => {
      const date = item.date.slice(0, 7)
      if (monthTransactionList.length === 0) {
        const monthTransactionItem: IMonthTransactionItem = {
          month: date,
          transactionList: [item]
        }
        monthTransactionList.push(monthTransactionItem)
      } else {
        for (let index = 0; index < monthTransactionList.length; index++) {
          const element = monthTransactionList[index];
          if (date === element.month) {
            const res = element.transactionList.find((child) => {
              return child.id === item.id
            })
            if (!res) {
              element.transactionList.push(item)
            }
            break
          }
          if (date !== element.month && index === monthTransactionList.length - 1) {
            const monthTransactionItem: IMonthTransactionItem = {
              month: date,
              transactionList: [item]
            }
            monthTransactionList.push(monthTransactionItem)
          }
        }
      }
    })
    if (data.transactionDate) {
      switch (data.transactionDate) {
        case 1:
          const arr1 = monthTransactionList.filter((item) => {
            const res = TransactionDatasetMock.datesApart(item.month, 1)
            return res
          })
          monthTransactionList = arr1
          break
        case 2:
          const arr2 = monthTransactionList.filter((item) => {
            const res = TransactionDatasetMock.datesApart(item.month, 3)
            return res
          })
          monthTransactionList = arr2
          break
        case 3:
          const arr3 = monthTransactionList.filter((item) => {
            const res = TransactionDatasetMock.datesApart(item.month, 6)
            return res
          })
          monthTransactionList = arr3
          break
        case 4:
          const arr4 = monthTransactionList.filter((item) => {
            const res = TransactionDatasetMock.datesApart(item.month, 12)
            return res
          })
          monthTransactionList = arr4
          break
      }
    }
    if (data.transactionType && data.transactionType !== 1) {
      for (let i = 0; i < monthTransactionList.length; i++) {
        const element = monthTransactionList[i];
        const arr = element.transactionList.filter((item) => {
          return item.type === data.transactionType
        })
        element.transactionList = arr
      }
    }

    const arr = monthTransactionList.filter((item) => {
      return item.transactionList.length > 0
    })

    return getFormattedResp(arr);
  }

  public static getTransactionList(data: IQueryTransaction) {
    if (data.searchText) {
      const arr = TransactionDatasetMock.transactionList.filter((item) => {
        return item.productName.includes(data.searchText as string)
      })
      return getFormattedResp(arr);
    }
    return getFormattedResp([])
  }

  public static getTransactionInfo(data: IQueryById) {
    const transactionInfo: ITransactionInfo = {
      id: 1,
      type: 1,
      state: 1,
      date: '',
      productName: '',
      productNumber: '',
      bankCardNumber: '',
      amount: 1000,
      status: []
    }
    TransactionDatasetMock.transactionInfoList.forEach((transaction) => {
      if (transaction.id === data.id) {
        transactionInfo.id = transaction.id
        transactionInfo.type = transaction.type
        transactionInfo.date = transaction.date
        transactionInfo.amount = transaction.amount
        transactionInfo.bankCardNumber = transaction.bankCardNumber
        transactionInfo.id = transaction.id
        transactionInfo.state = transaction.state
        transactionInfo.productName = transaction.productName
        transactionInfo.productNumber = transaction.productNumber
        transactionInfo.status = transaction.status
        transactionInfo.msg = transaction.msg
      }
    })
    return getFormattedResp(transactionInfo);
  }

  private static datesApart(date: string, type: number) {
    const year1 = date.slice(0, 4)
    const month1 = date.slice(5, 7)
    const year2 = new Date().getFullYear()
    const month2 = new Date().getMonth() + 1
    const totalMonth1 = Number(year1) * 12 + Number(month1)
    const totalMonth2 = Number(year2) * 12 + month2
    return Math.abs(totalMonth2 - totalMonth1) <= type
  }
}