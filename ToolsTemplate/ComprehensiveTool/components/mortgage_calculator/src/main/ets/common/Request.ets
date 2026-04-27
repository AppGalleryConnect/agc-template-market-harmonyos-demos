import { LoanPrimeRate } from '../types/Index';

export const queryLPRList = async (): Promise<Array<LoanPrimeRate>> => {
  return [{
    date: '2025/7/21', one: '3.00', five: '3.50',
  }, {
    date: '2025/6/20', one: '3.00', five: '3.50',
  }, {
    date: '2025/5/20', one: '3.00', five: '3.50',
  }, {
    date: '2025/4/21', one: '3.10', five: '3.60',
  }, {
    date: '2025/3/20', one: '3.10', five: '3.60',
  }, {
    date: '2025/2/20', one: '3.10', five: '3.60',
  }, {
    date: '2025/1/20', one: '3.10', five: '3.60',
  }, {
    date: '2024/12/20', one: '3.10', five: '3.60',
  }, {
    date: '2024/11/20', one: '3.10', five: '3.60',
  }, {
    date: '2024/10/20', one: '3.10', five: '3.60',
  }]
}
